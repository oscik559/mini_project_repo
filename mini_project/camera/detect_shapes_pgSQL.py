import cv2
import numpy as np
import pyrealsense2 as rs


def mean_shift_segmentation(image, sp=21, sr=51):
    return cv2.pyrMeanShiftFiltering(image, sp, sr)


def detect_shape(contour):
    epsilon = 0.02 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
    if len(approx) == 3:
        return "Triangle", approx
    elif len(approx) == 4:
        x, y, w, h = cv2.boundingRect(approx)
        aspect_ratio = float(w) / h
        return ("Square" if 0.95 <= aspect_ratio <= 1.1 else "Rectangle"), approx
    elif len(approx) == 5:
        return "Pentagon", approx
    elif len(approx) == 6:
        return "Hexagon", approx
    elif len(approx) > 6:
        return "Circle", approx
    else:
        return "Unknown", approx


def get_color_name_from_ranges(hsv_value, color_ranges):
    for color_name, (lower, upper) in color_ranges.items():
        if all(lower[i] <= hsv_value[i] <= upper[i] for i in range(3)):
            return "red" if color_name.startswith("red") else color_name
    return "Unknown"


def find_table_roi(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blurred, 100, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if not contours:
        print("No table detected.")
        return None, None, image

    largest_contour = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(largest_contour)
    roi = image[y + 20 : y + h - 50, x + 20 : x + w - 20]
    debug_image = image.copy()
    cv2.drawContours(debug_image, [largest_contour], -1, (0, 255, 0), 2)
    return roi, (x + 20, y + 20), debug_image


def detect_colored_shapes(roi, roi_origin, depth_frame, color_ranges):
    hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
    all_mask = np.zeros_like(hsv_roi[:, :, 0])
    for lower, upper in color_ranges.values():
        all_mask |= cv2.inRange(hsv_roi, lower, upper)

    contours, _ = cv2.findContours(all_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    output_image = roi.copy()
    center_points = []

    for contour in contours:
        if cv2.contourArea(contour) < 200:
            continue

        shape_name, approx = detect_shape(contour)
        mask = np.zeros_like(hsv_roi[:, :, 0])
        cv2.drawContours(mask, [contour], -1, 255, thickness=cv2.FILLED)
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

        center_points.append((cX, cY, color_name, shape_name, round(depth_meters, 3)))
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
    pipeline = rs.pipeline()
    config = rs.config()
    config.enable_stream(rs.stream.color, 1280, 720, rs.format.bgr8, 30)
    config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 30)
    profile = pipeline.start(config)

    depth_sensor = profile.get_device().first_depth_sensor()
    depth_scale = depth_sensor.get_depth_scale()
    print("Depth scale:", depth_scale)

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

    try:
        while True:
            frames = pipeline.wait_for_frames()
            color_frame = frames.get_color_frame()
            depth_frame = frames.get_depth_frame()
            if not color_frame or not depth_frame:
                continue

            image = np.asanyarray(color_frame.get_data())
            roi, roi_origin, debug_image = find_table_roi(image)
            if roi is None:
                break

            roi = mean_shift_segmentation(roi)
            center_points, annotated_roi = detect_colored_shapes(
                roi, roi_origin, depth_frame, color_ranges
            )
            combined_view = visualize_shapes(image, roi_origin, annotated_roi)

            print("Detected:", center_points)
            cv2.imshow("Detected Shapes", combined_view)

            key = cv2.waitKey(1) & 0xFF
            if key == 27 or key == ord("q"):
                break

    finally:
        pipeline.stop()
        cv2.destroyAllWindows()




def main():
    camera_pipeline()


if __name__ == "__main__":
    main()
