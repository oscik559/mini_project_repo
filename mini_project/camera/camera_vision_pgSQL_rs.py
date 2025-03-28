# tray_and_holder_detection.py

import math
import time

import cv2
import matplotlib.pyplot as plt
import numpy as np
import pyrealsense2 as rs

from config.app_config import CAMERA_DATA_PATH
from mini_project.database.db_handler_pgSQL import DatabaseHandler


def process_image(image_path, wait_key, db_handler):
    """
    Process the camera stream from the Intel D453i using pyrealsense2.
    Captures color and depth frames, processes each frame for object detection,
    and updates the database with the results.
    """

    # Start RealSense pipeline
    pipeline = rs.pipeline()
    config = rs.config()
    config.enable_stream(rs.stream.color, 1280, 720, rs.format.bgr8, 30)
    config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 30)
    profile = pipeline.start(config)

    # Get the depth intrinsics for any depth-to-real-world conversions.
    depth_stream = profile.get_stream(rs.stream.depth).as_video_stream_profile()
    intrinsics = depth_stream.get_intrinsics()

    depth_sensor = profile.get_device().first_depth_sensor()
    depth_scale = depth_sensor.get_depth_scale()
    print(depth_scale)

    # Initialize the old vector to compare with new values
    old_tray_position = [1000, 1000, 1000]
    old_holder_position = [1000, 1000, 1000]

    old_tray_angle_with_x = None
    old_holder_angle_with_x = None

    old_matched_slides = []

    tray_rel_position = []
    holder_rel_position = []

    tray_angle_with_x = None
    holder_angle_with_x = None

    try:
        while True:

            if image_path:
                # You're running in static image mode
                (
                    tray_rel_position,
                    holder_rel_position,
                    matched_slides,
                    tray_angle_with_x,
                    holder_angle_with_x,
                ) = color_image_process(color_image, wait_key, depth_frame, intrinsics)

                # Skip frame grabbing and pipeline calls
                break  # since you're just testing one image
            else:
                # RealSense mode
                frames = pipeline.wait_for_frames()
                color_frame = frames.get_color_frame()
                depth_frame = frames.get_depth_frame()

                # print(f"🟦 depth_frame: {depth_frame}")
                # print(
                #     f"🟦 intrinsics: {intrinsics.width}x{intrinsics.height}, "
                #     f"ppx={intrinsics.ppx}, ppy={intrinsics.ppy}, "
                #     f"fx={intrinsics.fx}, fy={intrinsics.fy}, "
                #     f"model={intrinsics.model}, coeffs={intrinsics.coeffs}"
                # )

                if not color_frame or not depth_frame:
                    continue

                color_image = np.asanyarray(color_frame.get_data())

                if color_image is None:
                    print(f"Error: No image frames retrieved.")
                    return

                # --- Process the color image ---
                (
                    tray_rel_position,
                    holder_rel_position,
                    matched_slides,
                    tray_angle_with_x,
                    holder_angle_with_x,
                ) = color_image_process(color_image, wait_key, depth_frame, intrinsics)

            # Convert numpy.float64 to native floats
            tray_rel_position = [float(value) for value in tray_rel_position]
            holder_rel_position = [float(value) for value in holder_rel_position]

            # Process matched objects if they changed.
            if matched_slides != old_matched_slides:
                old_matched_slides = matched_slides

            # Prepare data for the database
            Slide_index = [
                (match["closest_midpoint_index"], match["object_color"])
                for match in matched_slides
            ]

            if (
                vector_changed(tray_rel_position, old_tray_position)
                or tray_angle_with_x != old_tray_angle_with_x
            ):
                old_tray_position = tray_rel_position
                old_tray_angle_with_x = tray_angle_with_x

            if (
                vector_changed(holder_rel_position, old_holder_position)
                or holder_angle_with_x != old_holder_angle_with_x
            ):
                old_holder_position = holder_rel_position
                old_holder_angle_with_x = holder_angle_with_x

            merged_data_1 = f"🟢 Fixture_and_slide_position: {tray_rel_position}; {tray_angle_with_x}; {Slide_index};"
            merged_data_2 = (
                f"🟢 Holder_position: {holder_rel_position}; {holder_angle_with_x};"
            )
            print(merged_data_1)
            print(merged_data_2)

            # Check if tray_rel_position is empty and decide what to do:
            if not tray_rel_position:

                print("🟡 No Tray position detected, using default values.")
                tray_rel_position = [50.0, 150.0, 10.0]
                tray_angle_with_x = 90.0

            if not holder_rel_position:

                print("🟡 No Holder position detected, using default values.")
                holder_rel_position = [170.0, 420.0, 0.0]
                holder_angle_with_x = 90.0

            # --- Update the database ---
            update_camera_vision_database(
                db_handler,
                tray_rel_position,
                tray_angle_with_x,
                holder_rel_position,
                holder_angle_with_x,
                matched_slides,
            )
            # Exit if the user presses 'q'
            if cv2.waitKey(wait_key) & 0xFF == ord("q"):
                break
    finally:
        if not image_path:
            pipeline.stop()
        cv2.destroyAllWindows()


def color_image_process(image, wait_key, depth_frame, intrinsics):
    """
    function for processing the input color image.
    Replace this with the actual object detection and processing logic.

    Args:
        color_image (np.ndarray): Input color image.

    Returns:
        tuple: (tray_relative_position, matched_objects, angle_with_x)
    """
    # Example output (replace with actual detection results)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    _, thresh_image = cv2.threshold(
        cv2.GaussianBlur(gray_image, (5, 5), 0), 100, 255, cv2.THRESH_BINARY_INV
    )

    # Detect contours
    contours, _ = cv2.findContours(
        thresh_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )

    tray_rel_position = []
    holder_rel_position = []
    matched_slides = []
    tray_angle_with_x_axis = None
    holder_angle_with_x_axis = None
    closest_idx = None
    scaling_factor = None

    for contour in contours:
        if 50000 < cv2.contourArea(contour) < 170000:
            rect = cv2.minAreaRect(contour)
            box = cv2.boxPoints(rect).astype(np.int64)

            # Draw tray bounding box
            cv2.polylines(image, [box], isClosed=True, color=(0, 255, 0), thickness=2)

            # Detect red regions within the bounding box
            x, y, w, h = cv2.boundingRect(contour)
            hsv_roi = cv2.cvtColor(image[y : y + h, x : x + w], cv2.COLOR_BGR2HSV)
            red_mask = cv2.inRange(
                hsv_roi, np.array([0, 70, 50]), np.array([10, 255, 255])
            ) + cv2.inRange(hsv_roi, np.array([170, 70, 50]), np.array([180, 255, 255]))

            # Find red contours and identify the closest tray corner
            for red_contour in cv2.findContours(
                red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
            )[0]:
                if cv2.contourArea(red_contour) > 500:
                    red_center = np.mean(
                        cv2.boxPoints(cv2.minAreaRect(red_contour)), axis=0
                    ) + [
                        x,
                        y,
                    ]
                    closest_idx = np.argmin(
                        [np.linalg.norm(corner - red_center) for corner in box]
                    )

                    # Draw bounding box for the red contour
                    box_red = cv2.boxPoints(cv2.minAreaRect(red_contour)).astype(
                        np.int64
                    )
                    pts_red = np.array(
                        [
                            (box_red[0]) + (x, y),
                            (box_red[1]) + (x, y),
                            (box_red[2]) + (x, y),
                            (box_red[3]) + (x, y),
                        ]
                    ).astype(np.int64)
                    image = cv2.polylines(
                        image, [pts_red], isClosed=True, color=(0, 0, 255), thickness=2
                    )

                    # Determine tray points
                    tray_points = [box[closest_idx]]
                    next_idx = (closest_idx + 1) % 4
                    prev_idx = (closest_idx - 1) % 4
                    longer_corner_idx = (
                        next_idx
                        if np.linalg.norm(box[closest_idx] - box[next_idx])
                        > np.linalg.norm(box[closest_idx] - box[prev_idx])
                        else prev_idx
                    )

                    # Add 'POINT 1' and the remaining unmarked corners
                    tray_points.append(box[longer_corner_idx])
                    # shorter_corner_idx = (set(range(4)) - {closest_idx, longer_corner_idx}).pop()
                    remaining_indices = set(range(4)) - {closest_idx, longer_corner_idx}
                    shorter_corner_idx = min(
                        remaining_indices,
                        key=lambda idx: np.linalg.norm(box[closest_idx] - box[idx]),
                    )
                    tray_points.append(box[shorter_corner_idx])

                    # Determine the final unmarked corner as 'point3'
                    point3_idx = (
                        set(range(4))
                        - {closest_idx, longer_corner_idx, shorter_corner_idx}
                    ).pop()
                    tray_points.append(box[point3_idx])

                    # Draw tray points and labels
                    for i, pt in enumerate(tray_points):
                        cv2.circle(image, tuple(pt), 1, (0, 0, 255), -1)
                        cv2.putText(
                            image,
                            f"point{i}",
                            tuple(pt),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.4,
                            (255, 0, 0),
                            2,
                        )

                    # Find the angle between 'POINT 0' and 'POINT 1' with respect to the x-axis
                    point0 = tray_points[0]
                    point1 = tray_points[1]
                    dx, dy = point1[0] - point0[0], point1[1] - point0[1]
                    tray_angle_with_x_axis = math.degrees(math.atan2(dy, dx))

                    # Draw the angle value next to 'POINT 0'
                    angle_text = f"Angle: {tray_angle_with_x_axis:.2f}°"
                    cv2.putText(
                        image,
                        angle_text,
                        (point0[0] + 50, point0[1]),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.4,
                        (255, 0, 0),
                        2,
                    )

                    # Segment the ROI between POINT 0 and POINT 1
                    num_segments = 10
                    coordinates_top = []
                    coordinates_top.append((int(point0[0]), int(point0[1])))
                    for i in range(1, num_segments):
                        # Calculate the segment position
                        segment_ratio = i / num_segments
                        segment_x = int(
                            point0[0] + segment_ratio * (point1[0] - point0[0])
                        )
                        segment_y = int(
                            point0[1] + segment_ratio * (point1[1] - point0[1])
                        )

                        # Calculate the corresponding points on the opposite edge (point2 to point3)
                        point2 = tray_points[2]
                        point3 = tray_points[3]
                        line_start = (segment_x, segment_y)
                        line_end = (
                            int(point2[0] + segment_ratio * (point3[0] - point2[0])),
                            int(point2[1] + segment_ratio * (point3[1] - point2[1])),
                        )

                        # Draw vertical segmenting green line
                        cv2.line(image, line_start, line_end, (0, 255, 0), 1)
                        coordinates_top.append((segment_x, segment_y))

                    coordinates_top.append((int(point1[0]), int(point1[1])))
                    coordinates_bottom = []
                    coordinates_bottom.append((int(point2[0]), int(point2[1])))

                    # Calculate and append the coordinates for the divisions between POINT 2 and POINT 3
                    num_segments_edge2_to_3 = (
                        10  # Number of divisions you want along this edge
                    )
                    for i in range(1, num_segments_edge2_to_3 + 1):
                        # Calculate the segment position
                        segment_ratio = i / num_segments_edge2_to_3
                        segment_x = int(
                            point2[0] + segment_ratio * (point3[0] - point2[0])
                        )
                        segment_y = int(
                            point2[1] + segment_ratio * (point3[1] - point2[1])
                        )

                        # Append the coordinates as a tuple of integers
                        coordinates_bottom.append((segment_x, segment_y))

                    # Append point3 to the list as a tuple of integers
                    coordinates_bottom.append((int(point3[0]), int(point3[1])))

                    # Segment the ROI between POINT 0 and POINT 2 with two divisions
                    num_divisions = 2
                    for i in range(1, num_divisions):
                        # Calculate the segment position
                        division_ratio = i / (
                            num_divisions
                        )  # +1 to adjust for two segments
                        segment_x = int(
                            point0[0] + division_ratio * (point2[0] - point0[0])
                        )
                        segment_y = int(
                            point0[1] + division_ratio * (point2[1] - point0[1])
                        )

                        # Calculate the corresponding points on the opposite edge (point1 to point3)
                        line_start = (segment_x, segment_y)
                        line_end = (
                            int(point1[0] + division_ratio * (point3[0] - point1[0])),
                            int(point1[1] + division_ratio * (point3[1] - point1[1])),
                        )

                        # Draw horizontal segmenting green line
                        cv2.line(image, line_start, line_end, (0, 255, 0), 1)

                    # Draw midpoints for coordinates_top and coordinates_bottom
                    merged_midpoints = calculate_midpoints_and_draw(
                        image, coordinates_top
                    ) + calculate_midpoints_and_draw(image, coordinates_bottom)

                    # detect colored objects in ROI
                    roi = (x, y, w, h)
                    detected_objects = detect_colored_objects_in_roi(image, roi)

                    # Match objects to midpoints
                    matched_slides = match_objects_to_midpoints(
                        detected_objects, merged_midpoints
                    )

                    # for match in matched_objects:
                    #     print(f"Object color: {match['object_color']}")
                    #     print(f"Closest midpoint index: {match['closest_midpoint_index']}")

                    # Detect screw location
                    detected_screw = detect_screw_location(image)

                    screw_center_orange = []
                    screw_center_blue = []

                    for color, objects in detected_screw.items():
                        if color == "Screw_orange" and objects:
                            screw_center_orange = objects[0][
                                "center"
                            ]  # Assuming we take the first detected center
                        elif color == "Screw_blue" and objects:
                            screw_center_blue = objects[0]["center"]

                    # ======================= DEFINE ACTUAL DISTANCE BETWEEN REFERENCES =======================
                    Actual_distance_p0_p1 = 320  # in mm

                    # ======================= CALCULATE SCALING FACTOR =======================
                    pixel_distance_p0_p1 = math.sqrt(
                        (int(point1[0]) - int(point0[0])) ** 2
                        + (int(point1[1]) - int(point0[1])) ** 2
                    )
                    scaling_factor = Actual_distance_p0_p1 / pixel_distance_p0_p1

                    # ============== Calculate the relative angle between the screw centers =================
                    relative_angle_btw_screw_centers = calculate_relative_angle(
                        screw_center_orange, screw_center_blue, dx, dy
                    )

                    # ============== Calculate the relative position of the tray w.r.t. the detected screws =================
                    if (
                        screw_center_orange is not None
                        and len(screw_center_orange) != 0
                    ):
                        tray_rel_position = depth_image_process(
                            point0,
                            screw_center_orange,
                            scaling_factor,
                        )
                    display_hsv_image(image, (x, y, w, h))

        # For the slide holder
        if 5000 < cv2.contourArea(contour) < 17000:
            rect_ = cv2.minAreaRect(contour)
            box_ = cv2.boxPoints(rect_).astype(np.int64)

            # Draw the tray bounding box in blue
            cv2.polylines(image, [box_], isClosed=True, color=(255, 0, 0), thickness=2)

            # Detect red regions within the bounding box
            x_, y_, w_, h_ = cv2.boundingRect(contour)
            hsv_roi_ = cv2.cvtColor(
                image[y_ : y_ + h_, x_ : x_ + w_], cv2.COLOR_BGR2HSV
            )
            red_mask_ = cv2.inRange(
                hsv_roi_, np.array([0, 70, 50]), np.array([10, 255, 255])
            ) + cv2.inRange(
                hsv_roi_, np.array([170, 70, 50]), np.array([180, 255, 255])
            )

            # Find red contours and identify the closest tray corner
            for red_contour_ in cv2.findContours(
                red_mask_, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
            )[0]:
                if cv2.contourArea(red_contour_) > 50:
                    red_center_ = np.mean(
                        cv2.boxPoints(cv2.minAreaRect(red_contour_)), axis=0
                    ) + [
                        x_,
                        y_,
                    ]
                    closest_idx_ = np.argmin(
                        [np.linalg.norm(corner_ - red_center_) for corner_ in box_]
                    )

                    # Draw bounding box for the red contour
                    box_red_ = cv2.boxPoints(cv2.minAreaRect(red_contour_)).astype(
                        np.int64
                    )
                    pts_red_ = np.array(
                        [
                            (box_red_[0]) + (x_, y_),
                            (box_red_[1]) + (x_, y_),
                            (box_red_[2]) + (x_, y_),
                            (box_red_[3]) + (x_, y_),
                        ]
                    ).astype(np.int64)
                    image = cv2.polylines(
                        image, [pts_red_], isClosed=True, color=(0, 0, 255), thickness=2
                    )

                    # Determine tray points
                    tray_points_ = [box_[closest_idx_]]
                    next_idx_ = (closest_idx_ + 1) % 4
                    prev_idx_ = (closest_idx_ - 1) % 4
                    longer_corner_idx_ = (
                        next_idx_
                        if np.linalg.norm(box_[closest_idx_] - box_[next_idx_])
                        > np.linalg.norm(box_[closest_idx_] - box_[prev_idx_])
                        else prev_idx_
                    )

                    # Add 'POINT 1' and the remaining unmarked corners
                    tray_points_.append(box_[longer_corner_idx_])
                    # shorter_corner_idx = (set(range(4)) - {closest_idx, longer_corner_idx}).pop()
                    remaining_indices_ = set(range(4)) - {
                        closest_idx_,
                        longer_corner_idx_,
                    }
                    shorter_corner_idx_ = min(
                        remaining_indices_,
                        key=lambda idx_: np.linalg.norm(
                            box_[closest_idx_] - box_[idx_]
                        ),
                    )
                    tray_points_.append(box_[shorter_corner_idx_])

                    # Determine the final unmarked corner as 'point3'
                    point3_idx_ = (
                        set(range(4))
                        - {closest_idx_, longer_corner_idx_, shorter_corner_idx_}
                    ).pop()
                    tray_points_.append(box_[point3_idx_])

                    for i, pt in enumerate(tray_points_):
                        cv2.circle(image, tuple(pt), 3, (255, 0, 0), -1)
                        cv2.putText(
                            image,
                            f"p{i}",
                            tuple(pt),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.4,
                            (0, 255, 0),
                            2,
                        )

                    # Find the angle between 'POINT 0' and 'POINT 1' with respect to the x-axis
                    point0_ = tray_points_[0]
                    point1_ = tray_points_[1]
                    dx_, dy_ = point1_[0] - point0_[0], point1_[1] - point0_[1]
                    holder_angle_with_x_axis = math.degrees(math.atan2(dy_, dx_))

                    # ============== Draw the angle value next to 'POINT 0' ==============
                    angle_text_ = f"Angle: {holder_angle_with_x_axis:.2f} deg"
                    cv2.putText(
                        image,
                        angle_text_,
                        (point0_[0] + 50, point0_[1]),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.4,
                        (0, 255, 0),
                        2,
                    )

                    # ============== Calculate relative position of holder w.r.t. detected screw ==============
                    detected_screw = detect_screw_location(image)
                    screw_center_orange = (
                        detected_screw.get("Screw_orange", [])[0]["center"]
                        if detected_screw.get("Screw_orange")
                        else []
                    )

                    # ======================= CALCULATE SCALING FACTOR =======================
                    Actual_distance_p0_p1_ = 250  # in mm
                    pixel_distance_p0_p1_ = math.sqrt(
                        (int(point1_[0]) - int(point0_[0])) ** 2
                        + (int(point1_[1]) - int(point0_[1])) ** 2
                    )
                    scaling_factor_ = Actual_distance_p0_p1_ / pixel_distance_p0_p1_

                    if len(screw_center_orange) != 0 and scaling_factor_ is not None:
                        holder_rel_position = depth_image_process(
                            point0_, screw_center_orange, scaling_factor_
                        )

    # scale_percent = 90
    # width = int(image.shape[1] * scale_percent / 100)
    # height = int(image.shape[0] * scale_percent / 100)
    # dim = (width, height)  # Resize the image
    # resized_image = cv2.resize(image, dim, interpolation=cv2.INTER_AREA)

    # Show the resized image
    # cv2.imshow("tray and holder detection", resized_image)
    cv2.imshow("tray and holder detection", image)
    cv2.waitKey(wait_key)

    ## Draw contours on the original image
    # output_image = image.copy()
    # cv2.drawContours(output_image, contours, -1, (0, 255, 0), 2)
    ## Show the image
    # cv2.imshow("Contours", output_image)

    # cv2.waitKey(0)
    # cv2.destroyAllWindows()

    return (
        tray_rel_position,
        holder_rel_position,
        matched_slides,
        tray_angle_with_x_axis,
        holder_angle_with_x_axis,
    )


def calculate_midpoints_and_draw(image, coordinates, color=(0, 255, 0)):
    midpoints = []
    # Iterate through the coordinates list to calculate midpoints
    for i in range(len(coordinates) - 1):
        # Get the current coordinate and the next coordinate
        point1, point2 = coordinates[i], coordinates[i + 1]

        # Calculate the midpoint
        midpoint = ((point1[0] + point2[0]) // 2, (point1[1] + point2[1]) // 2)
        midpoints.append(midpoint)

        # Draw a circle at the midpoint
        cv2.circle(image, midpoint, 5, color, -1)

    return midpoints


def detect_colored_objects_in_roi(image, roi):
    # Define color ranges in HSV
    color_ranges = {
        "green": (np.array([30, 45, 80]), np.array([70, 160, 190])),  # Green range
        "orange": (np.array([10, 90, 100]), np.array([25, 255, 255])),  # Orange range
        "pink": (
            np.array([150, 120, 120]),
            np.array([175, 195, 165]),
        ),
    }
    detected_objects = {}

    # Crop the image to the ROI
    x, y, w, h = roi
    roi_image = image[y : y + h, x : x + w]

    # Convert the ROI to HSV color space
    hsv_roi = cv2.cvtColor(roi_image, cv2.COLOR_BGR2HSV)

    # Loop through each color range and create masks
    for color, (lower, upper) in color_ranges.items():
        # Create a mask for the current color
        mask = cv2.inRange(hsv_roi, lower, upper)

        # Find contours of the detected objects
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        detected_objects[color] = []

        for contour in contours:
            if 500 > cv2.contourArea(contour) > 200:  # Filter by area
                # Get the bounding box and centroid
                x_contour, y_contour, w_contour, h_contour = cv2.boundingRect(contour)
                # center = (x_contour + w_contour // 2, y_contour + h_contour // 2)

                # Adjust the center coordinates back to the full image
                adjusted_center_x = x_contour + w_contour // 2 + x  # add x from ROI
                adjusted_center_y = y_contour + h_contour // 2 + y  # add y from ROI
                center = (adjusted_center_x, adjusted_center_y)

                color_code = get_normalized_color(
                    roi_image, (x_contour, y_contour, w_contour, h_contour)
                )

                # Append detected object details
                detected_objects[color].append(
                    {
                        "contour": contour,
                        "bounding_box": (x_contour, y_contour, w_contour, h_contour),
                        "center": center,
                        "color_code": color_code,
                    }
                )
                cv2.rectangle(
                    roi_image,
                    (x_contour, y_contour),
                    (x_contour + w_contour, y_contour + h_contour),
                    (255, 0, 0),
                    2,
                )
                # cv2.circle(roi_image, center, 5, (0, 0, 255), -1)  # Red center
    return detected_objects


def get_normalized_color(image, bounding_box):
    """
    Computes the normalized average color (in RGB) for a region of interest.

    Args:
        image (np.ndarray): The source image (BGR format).
        bounding_box (tuple): A tuple (x, y, w, h) defining the ROI.

    Returns:
        str: A string representation of the normalized color, e.g. "[0.0, 0.0, 0.7]".
    """
    x, y, w, h = bounding_box
    roi = image[y : y + h, x : x + w]
    # Compute the average color over the ROI. The result is in BGR order.
    avg_color_bgr = np.average(np.average(roi, axis=0), axis=0)
    # Convert BGR to RGB
    avg_color_rgb = [avg_color_bgr[2], avg_color_bgr[1], avg_color_bgr[0]]
    # Normalize each channel and round the result to 2 decimal places.
    normalized = [round(float(c) / 255.0, 2) for c in avg_color_rgb]
    return normalized  # Return as a list of Python floats


def match_objects_to_midpoints(detected_objects, midpoints):
    """Match each detected object center to the closest midpoint."""
    object_midpoint_map = []

    # Iterate over detected objects by color
    for color, objects in detected_objects.items():
        for obj in objects:
            obj_center = obj["center"]
            closest_midpoint_idx = None
            min_distance = float("inf")

            # Iterate through the midpoints to find the closest one
            for i, midpoint in enumerate(midpoints):
                distance = calculate_distance(obj_center, midpoint)
                if distance < min_distance:
                    min_distance = distance
                    closest_midpoint_idx = i

            # Append the result as a dictionary with object details and matched midpoint index
            #     'object_center': obj_center,
            #     'closest_midpoint': midpoints[closest_midpoint_idx] if closest_midpoint_idx is not None else None
            object_midpoint_map.append(
                {
                    "object_color": color,
                    "color_code": obj.get("color_code", "[0.0, 0.0, 0.0]"),
                    "closest_midpoint_index": closest_midpoint_idx,
                }
            )

    return object_midpoint_map


def calculate_distance(point1, point2):
    """Calculate Euclidean distance between two points."""
    return np.sqrt((point1[0] - point2[0]) ** 2 + (point1[1] - point2[1]) ** 2)


def detect_screw_location(image):
    # Define color ranges in HSV
    color_ranges = {
        "Screw_orange": (
            # np.array([10, 45, 140]),
            # np.array([25, 160, 200]),
            np.array([5, 50, 150]),
            np.array([35, 200, 200]),
        ),  # Orange range for screw
        "Screw_blue": (
            # np.array([100, 110, 60]),
            # np.array([120, 185, 120]),
            np.array([90, 100, 50]),
            np.array([120, 220, 110]),
        ),  # Blue range for screw
    }
    detected_screw = {}

    height, width = image.shape[:2]
    roi = 0, 0, width, height
    x, y, w, h = 0, 0, width, height
    # Convert the ROI to HSV color space
    hsv_roi = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Loop through each color range and create masks
    for color, (lower, upper) in color_ranges.items():
        # Create a mask for the current color
        mask = cv2.inRange(hsv_roi, lower, upper)
        # Find contours of the detected objects
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        detected_screw[color] = []

        for contour in contours:
            # =============== AMEND AREA TO SUIT PURPOSE ===============
            if 50 < cv2.contourArea(contour) < 150:  # Filter by area
                # Get the bounding box and centroid
                x_contour, y_contour, w_contour, h_contour = cv2.boundingRect(contour)

                # Adjust the center coordinates back to the full image
                adjusted_center_x = x_contour + w_contour // 2 + x  # add x from ROI
                adjusted_center_y = y_contour + h_contour // 2 + y  # add y from ROI
                center = (adjusted_center_x, adjusted_center_y)

                # Append detected object details
                detected_screw[color].append(
                    {
                        "contour": contour,
                        "bounding_box": (x_contour, y_contour, w_contour, h_contour),
                        "center": center,
                    }
                )
                cv2.rectangle(
                    image,
                    (x_contour, y_contour),
                    (x_contour + w_contour, y_contour + h_contour),
                    (255, 0, 0),
                    2,
                )
    return detected_screw


def calculate_relative_angle(screw_center_orange, screw_center_blue, dx1, dy1):
    angle_between_lines = None

    if screw_center_orange and screw_center_blue:
        # Calculate the direction vector for the line connecting the screw centers
        dx2, dy2 = (
            screw_center_blue[0] - screw_center_orange[0],
            screw_center_blue[1] - screw_center_orange[1],
        )

        # Calculate the angles with respect to the x-axis using atan2
        angle1 = math.atan2(dy1, dx1)
        angle2 = math.atan2(dy2, dx2)

        # Calculate the difference between the angles
        angle_between_lines = math.degrees(abs(angle1 - angle2))

        # Normalize the angle to the range [0, 180]
        if angle_between_lines > 180:
            angle_between_lines = 360 - angle_between_lines

        # print("Angle between the lines:", angle_between_lines)
    else:
        print("Error: Could not find centers for 'Screw_orange'.")

    return angle_between_lines


def depth_image_process(point0, ref_point, scaling_factor):
    point0_relative_position = []
    # depth_stream = profile.get_stream(rs.stream.depth).as_video_stream_profile()
    # intrinsics = depth_stream.get_intrinsics()
    # intrinsics = rs.intrinsics()

    # Retrieve depth values at these points in meters
    # d1 = depth_frame.get_distance(point0[0], point0[1])
    # d2 = depth_frame.get_distance(point_ref[0], point_ref[1])
    # d_center = depth_frame.get_distance(int(intrinsics.ppx), int(intrinsics.ppy))

    # d1 = 1.02
    # d2 = 1.04

    pixel_distance_p0_screw = (
        math.sqrt((ref_point[0] - point0[0]) ** 2 + (ref_point[1] - point0[1]) ** 2)
    ) * scaling_factor

    relative__pixel_vector = [
        point0[0] - ref_point[0],  # X component
        point0[1] - ref_point[1],  # Y component
    ]

    point0_relative_position = [
        relative__pixel_vector[0] * scaling_factor,
        relative__pixel_vector[1] * scaling_factor,
        0.0,
    ]

    # if d1 == 0 or d2 == 0:
    #     print("Invalid depth values at one or both points.")
    # else:
    #     point_3d = rs.rs2_deproject_pixel_to_point(intrinsics, [int(point0[0]), int(point0[1])], d1)
    #     point_3d_ref = rs.rs2_deproject_pixel_to_point(intrinsics, [int(point_ref[0]), int(point_ref[1])], d2)

    #     distance = math.sqrt((point_3d_ref[0] - point_3d[0])**2 + (point_3d_ref[1] - point_3d[1])**2 + (point_3d_ref[2] - point_3d[2])**2)
    #     print("Distance between points:", distance, "meters")

    #     # Compute the position vector relative to the reference object
    #     point0_relative_position = [point_3d[0] - point_3d_ref[0],  # X component
    #                         point_3d[1] - point_3d_ref[1],  # Y component
    #                         point_3d[2] - point_3d_ref[2]]   # Z component

    return point0_relative_position


def display_hsv_image(image, roi):
    # Crop the image to the ROI
    x, y, w, h = roi
    # roi_image = image[y:y+h, x:x+w]

    # Convert the cropped ROI to HSV
    hsv_roi = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Split the channels for visualization
    h, s, v = cv2.split(hsv_roi)


def vector_changed(new_vector, old_vector, tolerance=5.0):
    # A function to check if the relative vector has changed significantly

    return any(abs(n - o) > tolerance for n, o in zip(new_vector, old_vector))


# camera_db_utils.py
# 🛑 with postgres


def update_camera_vision_database(
    db_handler,
    tray_position,
    tray_orientation,
    holder_position,
    holder_orientation,
    slide_detections,
):
    """
    Update the camera_vision table with detection results.
    """
    active_names = []  # to keep track of all object names that are active
    DEFAULT_BLACK_CODE = [0.0, 0.0, 0.0]
    # --- Update the Tray record ---
    tray_data = {
        "object_name": "Fixture",
        "object_color": "black",  # default color name
        "color_code": DEFAULT_BLACK_CODE,  # black in normalized RGB
        "pos_x": tray_position[0],
        "pos_y": tray_position[1],
        "pos_z": tray_position[2],
        "rot_x": 180.0,
        "rot_y": 0.0,
        "rot_z": 90 - tray_orientation,
        "usd_name": "Fixture.usd",
    }
    upsert_camera_vision_record(db_handler, **tray_data)
    active_names.append(tray_data["object_name"])

    # --- Update the Holder record ---
    holder_data = {
        "object_name": "Holder",
        "object_color": "black",
        "color_code": DEFAULT_BLACK_CODE,  # default color for holder
        "pos_x": holder_position[0],
        "pos_y": holder_position[1],
        "pos_z": holder_position[2] + 8.6,
        "rot_x": 180.0,
        "rot_y": 0.0,
        "rot_z": 90 - holder_orientation,
        "usd_name": "Slide_Holder.usd",
    }
    upsert_camera_vision_record(db_handler, **holder_data)
    active_names.append(holder_data["object_name"])

    # --- Update the Slide records ---
    for index, detection in enumerate(slide_detections, start=1):
        slide_name = f"Slide_{index}"
        slide_color = detection.get("object_color", "Black")
        closest_midpoint_index = detection.get("closest_midpoint_index")
        # Calculate slide position relative to the tray (example offsets)
        # slide_pos_x = tray_position[0] + 10 * index
        # slide_pos_y = tray_position[1] + 5 * index
        # slide_pos_z = tray_position[2] - 19

        # print(slide_detections)
        # print(closest_midpoint_index)
        if closest_midpoint_index < 10:
            slide_pos_x = (22.75 + (closest_midpoint_index * 30.5)) * 10
            slide_pos_y = 460
            slide_pos_z = tray_position[2] - 19
        else:
            slide_pos_x = (22.75 + ((closest_midpoint_index - 10) * 30.5)) * 10
            slide_pos_y = 1750
            slide_pos_z = tray_position[2] - 19

        # Use the color code computed during detection; if not available, default to black.
        slide_color_code = detection.get("color_code", DEFAULT_BLACK_CODE)
        slide_data = {
            "object_name": slide_name,
            "object_color": slide_color,
            "color_code": slide_color_code,
            "pos_x": slide_pos_y,
            "pos_y": slide_pos_x,
            "pos_z": slide_pos_z,
            "rot_x": 0.0,
            "rot_y": 0.0,
            "rot_z": 90,
            "usd_name": "Slide.usd",
        }
        upsert_camera_vision_record(db_handler, **slide_data)
        active_names.append(slide_name)

    # --- Clean up any records not currently detected ---
    cleanup_camera_vision_records(db_handler, active_names)


def upsert_camera_vision_record(
    db_handler,
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
    """
    Inserts a new row or updates the existing row (identified by object_name)
    in the camera_vision table, including the color_code field.
    """
    try:
        # Check if a record already exists for the given object_name
        query = "SELECT object_id FROM camera_vision WHERE object_name = %s"
        db_handler.cursor.execute(query, (object_name,))
        result = db_handler.cursor.fetchone()

        if result is None:
            # Insert a new row if no record exists
            insert_query = """
                INSERT INTO camera_vision
                (object_name, object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name, last_detected)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
            """
            db_handler.cursor.execute(
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
        else:
            # Update the existing row
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
            db_handler.cursor.execute(
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

        db_handler.conn.commit()

    except Exception as e:
        print(f"Database error in upsert_camera_vision_record: {e}")
        db_handler.conn.rollback()


def cleanup_camera_vision_records(db_handler, active_object_names):
    """
    Deletes any rows from camera_vision whose object_name is not in the active list.
    """
    try:
        if not active_object_names:
            # Avoid executing an invalid SQL statement
            print("Warning: No active object names provided. Skipping cleanup.")
            return

        # Create a safe query with placeholders for each item
        placeholders = ",".join(["%s"] * len(active_object_names))
        delete_query = (
            f"DELETE FROM camera_vision WHERE object_name NOT IN ({placeholders})"
        )

        db_handler.cursor.execute(delete_query, active_object_names)
        db_handler.conn.commit()

    except Exception as e:
        print(f"Database error in cleanup_camera_vision_records: {e}")
        db_handler.conn.rollback()


if __name__ == "__main__":
    db = DatabaseHandler()
    image_path = None
    # image_path = CAMERA_DATA_PATH / "image_1.png"

    wait_key = 1000
    process_image(image_path=image_path, wait_key=wait_key, db_handler=db)
