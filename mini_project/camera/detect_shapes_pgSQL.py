# detect_shapes_pgSQL.py

import cv2
import numpy as np
import pyrealsense2 as rs
import logging
from datetime import datetime
from collections import defaultdict
from mini_project.database.connection import get_connection

logger = logging.getLogger("ShapeDetection")

# ------------------- Constants -------------------
MIN_SHAPE_AREA = 200
MAX_SHAPE_AREA = 5000
SCREW_TO_SCREW = 252.0  # mm
SCREW_TIMEOUT_SEC = 3
POSITION_TOLERANCE_MM = 10

# ------------------- Globals -------------------
shape_counter = defaultdict(int)
last_known_screw_positions = {}
last_screw_update_time = None
known_objects = {}  # {(shape_type, color): [{x, y, z, name}]}


# ------------------- Color Ranges -------------------
color_ranges = {
    "red1": (np.array([0, 50, 50]), np.array([8, 255, 255])),
    "red2": (np.array([170, 50, 50]), np.array([180, 255, 255])),
    "orange": (np.array([9, 50, 50]), np.array([19, 255, 255])),
    "yellow": (np.array([20, 50, 50]), np.array([30, 255, 255])),
    "green": (np.array([35, 50, 50]), np.array([85, 255, 255])),
    "blue": (np.array([90, 50, 50]), np.array([140, 255, 255])),
    "pink": (np.array([145, 50, 50]), np.array([165, 255, 255])),
    "black": (np.array([0, 0, 0]), np.array([180, 255, 50])),
}


# ------------------- Helpers -------------------
def map_shape_to_object(shape_name):
    shape_name = shape_name.lower()
    mapping = {
        "circle": "cylinder",
        "square": "cube",
        "rectangle": "cuboid",
        "triangle": "wedge",
        "pentagon": "pentagonal prism",
        "hexagon": "hexagonal prism",
    }
    return mapping.get(shape_name, "unknown")


def normalize_rgb_color(bgr):
    b, g, r = bgr
    return [round(r / 255.0, 2), round(g / 255.0, 2), round(b / 255.0, 2)]


def mean_shift_segmentation(image, sp=21, sr=51):
    return cv2.pyrMeanShiftFiltering(image, sp, sr)


def get_color_name_from_ranges(hsv_value, color_ranges):
    for color_name, (lower, upper) in color_ranges.items():
        if all(lower[i] <= hsv_value[i] <= upper[i] for i in range(3)):
            return "red" if color_name.startswith("red") else color_name
    return "Unknown"


def detect_screw_positions(screw_roi, depth_frame, roi_origin):
    hsv = cv2.cvtColor(screw_roi, cv2.COLOR_BGR2HSV)

    screw_colors = {
        "orange": (np.array([9, 50, 50]), np.array([19, 255, 255])),
        "blue": (np.array([90, 50, 50]), np.array([140, 255, 255])),
    }

    screw_positions = {}

    for color_name, (lower, upper) in screw_colors.items():
        mask = cv2.inRange(hsv, lower, upper)
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        if not contours:
            continue

        largest = max(contours, key=cv2.contourArea)
        area = cv2.contourArea(largest)

        # 🚫 Area filter: only consider reasonable screw sizes
        if area < 100 or area > 1200:
            continue

        # # 🔄 Shape filtering (optional): validate geometry
        # approx = cv2.approxPolyDP(
        #     largest, 0.04 * cv2.arcLength(largest, True), True
        # )

        # if color_name == "orange" and len(approx) < 6:
        #     continue  # orange should be circular-ish

        # if color_name == "blue" and not 4 <= len(approx) <= 6:
        #     continue  # blue should be square-ish

        # ✅ Compute center
        M = cv2.moments(largest)
        if M["m00"] == 0:
            continue

        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])
        real_cX = roi_origin[0] + cX
        real_cY = roi_origin[1] + cY
        depth = depth_frame.get_distance(real_cX, real_cY)

        screw_positions[color_name] = (real_cX, real_cY, depth)

        # 🎯 Mark center
        cv2.circle(screw_roi, (cX, cY), 3, (0, 0, 0), -1)  # black dot at center

        # 🟠 Orange circle / 🔵 Blue square
        if color_name == "orange":
            cv2.circle(screw_roi, (cX, cY), 12, (0, 140, 255), 2)
        elif color_name == "blue":
            cv2.rectangle(
                screw_roi, (cX - 12, cY - 12), (cX + 12, cY + 12), (255, 0, 0), 2
            )

        cv2.putText(
            screw_roi,
            f"{color_name} screw",
            (cX - 25, cY - 18),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.4,
            (0, 0, 0),
            1,
        )

    return screw_positions


def find_table_roi(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blurred, 100, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if not contours:
        logger.warning("⚠️  No table detected.")
        return None, None, image

    largest_contour = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(largest_contour)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)

    roi = image[y + 20 : y + h - 50, x + 20 : x + w - 20]
    cv2.imshow("Table_ROI", roi)

    debug_image = image.copy()
    cv2.drawContours(debug_image, [largest_contour], -1, (0, 255, 0), 2)
    cv2.imshow("debug_image", debug_image)
    return roi, (x + 20, y + 20), debug_image


def upsert_camera_vision_record(
    conn,
    object_name,
    object_color,
    color_code,
    pos_x,
    pos_y,
    pos_z,
    rot_x,
    rot_y,
    rot_z,
    usd_name,
):
    try:
        cursor = conn.cursor()
        query = "SELECT object_id FROM camera_vision WHERE object_name = %s"
        cursor.execute(query, (object_name,))
        result = cursor.fetchone()

        if result is None:
            insert_query = """
                INSERT INTO camera_vision
                (object_name, object_color, color_code, pos_x, pos_y, pos_z,
                 rot_x, rot_y, rot_z, usd_name, last_detected)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
            """
            cursor.execute(
                insert_query,
                (
                    object_name,
                    object_color,
                    color_code,
                    pos_x,
                    pos_y,
                    pos_z,
                    rot_x,
                    rot_y,
                    rot_z,
                    usd_name,
                ),
            )
            logger.info(f"➕ Inserted {object_name} into camera_vision")
        else:
            update_query = """
                UPDATE camera_vision
                SET object_color = %s,
                    color_code = %s,
                    pos_x = %s,
                    pos_y = %s,
                    pos_z = %s,
                    rot_x = %s,
                    rot_y = %s,
                    rot_z = %s,
                    usd_name = %s,
                    last_detected = NOW()
                WHERE object_name = %s
            """
            cursor.execute(
                update_query,
                (
                    object_color,
                    color_code,
                    pos_x,
                    pos_y,
                    pos_z,
                    rot_x,
                    rot_y,
                    rot_z,
                    usd_name,
                    object_name,
                ),
            )
            logger.info(f"🔁 Updated {object_name} in camera_vision")
        conn.commit()

    except Exception as e:
        print(f"Database error in upsert_camera_vision_record: {e}")
        conn.rollback()


def detect_shape(contour):
    epsilon = 0.02 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
    if len(approx) == 3:
        return "Triangle", approx
    elif len(approx) == 4:
        x, y, w, h = cv2.boundingRect(approx)
        aspect_ratio = float(w) / h
        return ("Square" if 0.95 <= aspect_ratio <= 1.2 else "Rectangle"), approx
    elif len(approx) == 5:
        return "Pentagon", approx
    elif len(approx) == 6:
        return "Hexagon", approx
    elif len(approx) > 6:
        return "Circle", approx
    else:
        return "Unknown", approx


def detect_colored_shapes(
    roi, roi_origin, depth_frame, conn, origin_px, scaling_factor, screw_positions
):

    hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
    all_mask = np.zeros_like(hsv_roi[:, :, 0])
    for lower, upper in color_ranges.values():
        all_mask |= cv2.inRange(hsv_roi, lower, upper)

    # 🔍 Detect screws *inside* the ROI
    if "orange" not in screw_positions or "blue" not in screw_positions:
        logger.warning("🟠🔵 Missing screws! Cannot compute relative positions.")
        return [], roi

    # 📏 Compute scaling factor from screw distance
    ox, oy, _ = screw_positions["orange"]
    bx, by, _ = screw_positions["blue"]
    pixel_dist = np.linalg.norm([bx - ox, by - oy])
    actual_mm = SCREW_TO_SCREW  # real-world mm between screws
    scaling_factor = actual_mm / pixel_dist

    origin_px = (ox, oy)

    contours, _ = cv2.findContours(all_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    output_image = roi.copy()
    center_points = []

    for contour in contours:

        area = cv2.contourArea(contour)
        # ✅ Filter shapes by contour area (tune as needed)
        if area < MIN_SHAPE_AREA or area > MAX_SHAPE_AREA:
            continue

        shape_name, approx = detect_shape(contour)
        mask = np.zeros_like(hsv_roi[:, :, 0])
        cv2.drawContours(mask, [contour], -1, 255, thickness=cv2.FILLED)
        x, y, w, h = cv2.boundingRect(contour)
        bgr = tuple(int(v) for v in cv2.mean(cv2.bitwise_and(roi, roi, mask=mask))[:3])

        mean_hsv = tuple(map(int, cv2.mean(hsv_roi, mask=mask)[:3]))
        color_name = get_color_name_from_ranges(mean_hsv, color_ranges)

        M = cv2.moments(contour)
        if M["m00"] == 0:
            continue
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])
        real_cX = roi_origin[0] + cX
        real_cY = roi_origin[1] + cY
        depth_meters = depth_frame.get_distance(real_cX, real_cY)
        depth_mm = depth_meters * 1000  # convert to millimeters

        # 🧮 Compute relative mm from orange screw
        rel_x_mm = (real_cX - roi_origin[0] - ox) * scaling_factor
        rel_y_mm = (real_cY - roi_origin[1] - oy) * scaling_factor

        mean_bgr = cv2.mean(cv2.bitwise_and(roi, roi, mask=mask))[:3]
        color_code = normalize_rgb_color(mean_bgr)
        rot_z = cv2.minAreaRect(contour)[-1]

        shape_type = map_shape_to_object(shape_name)

        # return center_points, output_image
        matched_name = None
        for obj in known_objects.get(color_name, []):
            dx = abs(obj["x"] - rel_x_mm)
            dy = abs(obj["y"] - rel_y_mm)
            if dx < POSITION_TOLERANCE_MM and dy < POSITION_TOLERANCE_MM:
                matched_name = obj["name"]
                obj.update({"x": rel_x_mm, "y": rel_y_mm, "z": depth_mm})
                break

        if matched_name:
            object_name = matched_name
        else:
            shape_counter[shape_type] += 1
            object_name = f"{shape_type} {shape_counter[shape_type]}"
            known_objects.setdefault(color_name, []).append(
                {"x": rel_x_mm, "y": rel_y_mm, "z": depth_mm, "name": object_name}
            )

        usd_name = f"{shape_type}.usd"

        upsert_camera_vision_record(
            conn,
            object_name,
            color_name,
            color_code,
            rel_x_mm,
            rel_y_mm,
            depth_mm,
            0.0,
            0.0,
            rot_z,
            usd_name,
        )

        center_points.append((cX, cY, color_name, shape_name, round(depth_meters, 3)))
        logger.info(
            f"🧩 Detected {color_name} {shape_name} → stored as '{object_name}' "
            f"(x={rel_x_mm:.1f}mm, y={rel_y_mm:.1f}mm, z={depth_mm:.1f}mm)"
        )

        cv2.drawContours(output_image, [approx], -1, (0, 255, 0), 2)
        cv2.putText(
            output_image,
            f"{color_name} {shape_name}",
            (cX - 20, cY - 20),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.3,
            (0, 0, 0),
            1,
        )
        cv2.putText(
            output_image,
            f"{depth_meters:.2f}m",
            (cX - 20, cY - 8),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.3,
            (255, 0, 255),
            1,
        )
        cv2.circle(output_image, (cX, cY), 2, (255, 0, 0), -1)

    return center_points, output_image


def visualize_shapes(image, roi_origin, annotated_roi):
    x, y = roi_origin
    h, w = annotated_roi.shape[:2]
    combined = image.copy()
    combined[y : y + h, x : x + w] = annotated_roi
    return combined


def camera_pipeline():
    conn = get_connection()

    pipeline = rs.pipeline()
    config = rs.config()
    config.enable_stream(rs.stream.color, 1280, 720, rs.format.bgr8, 30)
    config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 30)
    profile = pipeline.start(config)

    depth_sensor = profile.get_device().first_depth_sensor()
    depth_scale = depth_sensor.get_depth_scale()
    logger.info("🔍 Depth scale: %s", depth_scale)

    try:
        while True:
            frames = pipeline.wait_for_frames()
            color_frame = frames.get_color_frame()
            depth_frame = frames.get_depth_frame()
            if not color_frame or not depth_frame:
                continue

            image = np.asanyarray(color_frame.get_data())

            roi, roi_origin, debug_image = find_table_roi(image)
            # Extract screw ROI (top edge of the main ROI)
            screw_roi_height = 100
            screw_roi = roi[0:screw_roi_height, 180:-180]
            cv2.rectangle(
                roi,
                (180, 0),
                (roi.shape[1] - 180, screw_roi_height),
                (0, 255, 0),
                2,
            )

            if roi is None:
                break

            roi = mean_shift_segmentation(roi)
            global last_known_screw_positions
            screw_positions = detect_screw_positions(screw_roi, depth_frame, roi_origin)

            # 🔁 Overlay annotated screw_roi back into roi so markings are visible
            roi[0 : screw_roi.shape[0], 180:-180] = screw_roi

            current_time = datetime.now()

            if "orange" in screw_positions and "blue" in screw_positions:
                last_known_screw_positions = screw_positions
                last_screw_update_time = current_time
                logger.debug("✅ Screw positions updated")

            elif last_known_screw_positions and last_screw_update_time:
                time_since_seen = (
                    current_time - last_screw_update_time
                ).total_seconds()

                if time_since_seen > SCREW_TIMEOUT_SEC:
                    logger.warning("⏰ Screw positions expired — skipping frame")
                    continue  # Don’t use outdated screws
                else:
                    screw_positions = last_known_screw_positions
                    logger.warning(
                        f"⚠️    Using last-known screw positions (stale for {time_since_seen:.1f}s)"
                    )
            else:
                logger.warning("❌ No valid screw data available — skipping frame")
                continue

            # Extract screw positions
            orange_screw = screw_positions["orange"]
            blue_screw = screw_positions["blue"]

            # Compute pixel distance and scaling factor
            pixel_dist = np.linalg.norm(
                np.array(orange_screw[:2]) - np.array(blue_screw[:2])
            )
            scaling_factor = (
                SCREW_TO_SCREW / pixel_dist
            )  # mm is real-world screw distance

            center_points, annotated_roi = detect_colored_shapes(
                roi,
                roi_origin,
                depth_frame,
                conn,
                origin_px=orange_screw[:2],
                scaling_factor=scaling_factor,
                screw_positions=screw_positions,
            )

            conn.commit()
            combined_view = visualize_shapes(image, roi_origin, annotated_roi)

            logger.debug("📌 Detected: %s", center_points)
            cv2.imshow("Detected Shapes", combined_view)

            key = cv2.waitKey(10) & 0xFF
            if key == 27 or key == ord("q"):
                break

    finally:
        pipeline.stop()
        conn.close()
        cv2.destroyAllWindows()


def main():
    camera_pipeline()


if __name__ == "__main__":
    main()
