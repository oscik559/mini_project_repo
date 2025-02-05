# tray_and_holder_detection.py
import sys

from db_handler import DatabaseHandler

import cv2
import numpy as np
import math
import matplotlib.pyplot as plt
# import pyrealsense2 as rs
import time
# import rospy
# from geometry_msgs.msg import Vector3
# from std_msgs.msg import String


from db_handler import DatabaseHandler

def process_image(image_path, wait_key):
    """
    Process a still image from the local drive for object detection and store results in the database.

    Args:
        image_path (str): Path to the input image file.
        wait_key (int): Time to wait for a keypress in milliseconds.
    """
    db = DatabaseHandler()  # Initialize database handler

    old_vector = [1000, 1000, 1000]
    old_angle_with_x = None
    old_matched_objects = []

    try:
        while True:
            # Load the image
            color_image = cv2.imread(image_path)
            if color_image is None:
                print(f"Error: Could not load image from {image_path}")
                return

            # Process the image
            relative_vector, matched_objects, angle_with_x = color_image_process(color_image, wait_key)

            # Convert np.float64 values to Python float
            relative_vector = [float(value) for value in relative_vector]

            if matched_objects != old_matched_objects:
                old_matched_objects = matched_objects

            # Prepare data for the database
            Slide_index = [(match['closest_midpoint_index'], match['object_color']) for match in matched_objects]

            if vector_changed(relative_vector, old_vector) or angle_with_x != old_angle_with_x:
                old_vector = relative_vector
                old_angle_with_x = angle_with_x

            # Construct result string
            merged_data = f"tray_and_slide_position: {relative_vector}; {angle_with_x}; {Slide_index};"
            print(merged_data)  # Print for debugging

            # Store results in the database
            store_camera_vision_data(db, relative_vector, angle_with_x, matched_objects)

    finally:
        db.close()  # Ensure database connection is closed
        cv2.destroyAllWindows()


def store_camera_vision_data(db, relative_vector, angle, matched_objects):
    """
    Insert tray and holder detection results into the camera_vision table.

    Args:
        db (DatabaseHandler): Database handler instance.
        relative_vector (list): [X, Y, Z] position of the tray.
        angle (float): Angle with respect to X-axis.
        matched_objects (list): List of detected objects with colors.
    """
    try:
        with db.conn:
            for index, (midpoint_index, color) in enumerate(matched_objects):
                object_name = f"Detected_Object_{index}"
                pos_x, pos_y, pos_z = relative_vector if len(relative_vector) == 3 else (0, 0, 0)
                rot_x, rot_y, rot_z = 0.0, 0.0, angle  # Assuming only Z-axis rotation

                db.cursor.execute("""
                    INSERT INTO camera_vision (object_name, object_color, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (object_name, color, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, "unknown.usd"))

            db.conn.commit()
            print("Camera vision data inserted successfully.")

    except Exception as e:
        print(f"Error inserting camera vision data: {e}")


def color_image_process(image, wait_key):
    """
    Ffunction for processing the input color image.
    Replace this with the actual object detection and processing logic.

    Args:
        color_image (np.ndarray): Input color image.

    Returns:
        tuple: (relative_vector, matched_objects, angle_with_x)
    """
    # Example output (replace with actual detection results)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    _, thresh_image = cv2.threshold(cv2.GaussianBlur(gray_image, (5, 5), 0), 100, 255, cv2.THRESH_BINARY_INV)

    # Detect contours
    contours, _ = cv2.findContours(thresh_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    relative_vector =[]
    matched_objects = []
    angle_with_x_axis = None
    screw_center = []

    for contour in contours:
        if 5000 < cv2.contourArea(contour) < 170000:
            rect = cv2.minAreaRect(contour)
            box = cv2.boxPoints(rect).astype(np.int64)

            # Draw tray bounding box
            cv2.polylines(image, [box], isClosed=True, color=(0, 255, 0), thickness=2)

            # Detect red regions within the bounding box
            x, y, w, h = cv2.boundingRect(contour)
            hsv_roi = cv2.cvtColor(image[y:y+h, x:x+w], cv2.COLOR_BGR2HSV)
            red_mask = cv2.inRange(hsv_roi, np.array([0, 70, 50]), np.array([10, 255, 255])) + \
                    cv2.inRange(hsv_roi, np.array([170, 70, 50]), np.array([180, 255, 255]))

            # Find red contours and identify the closest tray corner
            for red_contour in cv2.findContours(red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]:
                if cv2.contourArea(red_contour) > 500:
                    red_center = np.mean(cv2.boxPoints(cv2.minAreaRect(red_contour)), axis=0) + [x, y]
                    closest_idx = np.argmin([np.linalg.norm(corner - red_center) for corner in box])

                    # Draw bounding box for the red contour
                    box_red = cv2.boxPoints(cv2.minAreaRect(red_contour)).astype(np.int64)
                    pts_red=np.array([(box_red[0]) + (x,y),(box_red[1]) + (x,y),(box_red[2]) + (x,y) ,(box_red[3]) + (x,y)]).astype(np.int64)
                    image = cv2.polylines(image, [pts_red], isClosed=True, color=(0, 0, 255), thickness=2)

                    # Determine tray points
                    tray_points = [box[closest_idx]]
                    next_idx = (closest_idx + 1) % 4
                    prev_idx = (closest_idx - 1) % 4
                    longer_corner_idx = next_idx if np.linalg.norm(box[closest_idx] - box[next_idx]) > \
                                        np.linalg.norm(box[closest_idx] - box[prev_idx]) else prev_idx

                    # Add 'POINT 1' and the remaining unmarked corners
                    tray_points.append(box[longer_corner_idx])
                    # shorter_corner_idx = (set(range(4)) - {closest_idx, longer_corner_idx}).pop()
                    remaining_indices = set(range(4)) - {closest_idx, longer_corner_idx}
                    shorter_corner_idx = min(remaining_indices, key=lambda idx: np.linalg.norm(box[closest_idx] - box[idx]))
                    tray_points.append(box[shorter_corner_idx])

                    # Determine the final unmarked corner as 'point3'
                    point3_idx = (set(range(4)) - {closest_idx, longer_corner_idx, shorter_corner_idx}).pop()
                    tray_points.append(box[point3_idx])

                    # Draw tray points and labels
                    for i, pt in enumerate(tray_points):
                        cv2.circle(image, tuple(pt), 1, (0, 0, 255), -1)
                        cv2.putText(image, f'point{i}', tuple(pt), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 0, 0), 2)

                    # Find the angle between 'POINT 0' and 'POINT 1' with respect to the x-axis
                    point0 = tray_points[0]
                    point1 = tray_points[1]
                    dx, dy = point1[0] - point0[0], point1[1] - point0[1]
                    angle_with_x_axis = math.degrees(math.atan2(dy, dx))

                    # Draw the angle value next to 'POINT 0'
                    angle_text = f"Angle: {angle_with_x_axis:.2f}°"
                    cv2.putText(image, angle_text, (point0[0] + 50, point0[1]), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 0, 0), 2)

                    # Segment the ROI between POINT 0 and POINT 1
                    num_segments = 10
                    coordinates_top = []
                    coordinates_top.append((int(point0[0]), int(point0[1])))
                    for i in range(1, num_segments):
                        # Calculate the segment position
                        segment_ratio = i / num_segments
                        segment_x = int(point0[0] + segment_ratio * (point1[0] - point0[0]))
                        segment_y = int(point0[1] + segment_ratio * (point1[1] - point0[1]))

                        # Calculate the corresponding points on the opposite edge (point2 to point3)
                        point2 = tray_points[2]
                        point3 = tray_points[3]
                        line_start = (segment_x, segment_y)
                        line_end = (int(point2[0] + segment_ratio * (point3[0] - point2[0])),
                                    int(point2[1] + segment_ratio * (point3[1] - point2[1])))

                        # Draw vertical segmenting green line
                        cv2.line(image, line_start, line_end, (0, 255, 0), 1)
                        coordinates_top.append((segment_x, segment_y))

                    coordinates_top.append((int(point1[0]), int(point1[1])))
                    coordinates_bottom = []
                    coordinates_bottom.append((int(point2[0]), int(point2[1])))

                    # Calculate and append the coordinates for the divisions between POINT 2 and POINT 3
                    num_segments_edge2_to_3 = 10  # Number of divisions you want along this edge
                    for i in range(1, num_segments_edge2_to_3 + 1):
                        # Calculate the segment position
                        segment_ratio = i / num_segments_edge2_to_3
                        segment_x = int(point2[0] + segment_ratio * (point3[0] - point2[0]))
                        segment_y = int(point2[1] + segment_ratio * (point3[1] - point2[1]))

                        # Append the coordinates as a tuple of integers
                        coordinates_bottom.append((segment_x, segment_y))

                    # Append point3 to the list as a tuple of integers
                    coordinates_bottom.append((int(point3[0]), int(point3[1])))

                    # Segment the ROI between POINT 0 and POINT 2 with two divisions
                    num_divisions = 2
                    for i in range(1, num_divisions):
                        # Calculate the segment position
                        division_ratio = i / (num_divisions)  # +1 to adjust for two segments
                        segment_x = int(point0[0] + division_ratio * (point2[0] - point0[0]))
                        segment_y = int(point0[1] + division_ratio * (point2[1] - point0[1]))

                        # Calculate the corresponding points on the opposite edge (point1 to point3)
                        line_start = (segment_x, segment_y)
                        line_end = (int(point1[0] + division_ratio * (point3[0] - point1[0])),
                                    int(point1[1] + division_ratio * (point3[1] - point1[1])))

                        # Draw horizontal segmenting green line
                        cv2.line(image, line_start, line_end, (0, 255, 0), 1)

                    # Draw midpoints for coordinates_top and coordinates_bottom
                    merged_midpoints = calculate_midpoints_and_draw(image, coordinates_top) + calculate_midpoints_and_draw(image, coordinates_bottom)

                    # detect colored objects in ROI
                    roi = (x, y, w, h)
                    detected_objects = detect_colored_objects_in_roi(image, roi)

                    # Match objects to midpoints
                    matched_objects = match_objects_to_midpoints(detected_objects, merged_midpoints)

                    # for match in matched_objects:
                    #     print(f"Object color: {match['object_color']}")
                    #     print(f"Closest midpoint index: {match['closest_midpoint_index']}")

                    # Detect screw location
                    detected_screw = detect_screw_location(image)

                    screw_center_orange = []
                    screw_center_blue = []
                    for color, objects in detected_screw.items():
                        if color == 'Screw_orange' and objects:
                            screw_center_orange = objects[0]['center']  # Assuming we take the first detected center
                        elif color == 'Screw_blue' and objects:
                            screw_center_blue = objects[0]['center']

                    Actual_distance_p0_p1 = 320 # in mm
                    pixel_distance_p0_p1 = math.sqrt((int(point1[0]) - int(point0[0]))**2 + (int(point1[1]) - int(point0[1]))**2)
                    scaling_factor = Actual_distance_p0_p1/pixel_distance_p0_p1

                    # calculate relative angle
                    angle = calculate_relative_angle(screw_center_orange, screw_center_blue, dx, dy)

                    # Relative position of tray w.r.t screw on YuMi foot
                    if len(screw_center_orange) != 0:
                        relative_vector = depth_image_process(point0, screw_center_orange, scaling_factor)
                    display_hsv_image(image, (x, y, w, h))



    scale_percent = 90
    width = int(image.shape[1] * scale_percent / 100)
    height = int(image.shape[0] * scale_percent / 100)
    dim = (width, height) # Resize the image
    resized_image = cv2.resize(image, dim, interpolation=cv2.INTER_AREA) # Show the resized image

    cv2.imshow('tray and holder detection', resized_image)
    cv2.waitKey(wait_key)

    ## Draw contours on the original image
    # output_image = image.copy()
    # cv2.drawContours(output_image, contours, -1, (0, 255, 0), 2)
    ## Show the image
    # cv2.imshow("Contours", output_image)

    # cv2.waitKey(0)
    # cv2.destroyAllWindows()

    return relative_vector, matched_objects, angle_with_x_axis

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
        'green': (np.array([30, 45, 80]), np.array([70, 160, 190])),  # Green range
        'orange': (np.array([10, 90, 100]), np.array([25, 255, 255])),  # Orange range
        'pink': (np.array([150, 120, 120]), np.array([175, 195, 165])),  # Grey range (adjust as needed)
        # 'pink': (np.array([140, 110, 95]), np.array([180, 195, 140])),  # Grey range (adjust as needed)
    }
    detected_objects = {}

    # Crop the image to the ROI
    x, y, w, h = roi
    roi_image = image[y:y+h, x:x+w]

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

                # Append detected object details
                detected_objects[color].append({
                    'contour': contour,
                    'bounding_box': (x_contour, y_contour, w_contour, h_contour),
                    'center': center
                })
                cv2.rectangle(roi_image, (x_contour, y_contour), (x_contour + w_contour, y_contour + h_contour), (255, 0, 0), 2)
                # cv2.circle(roi_image, center, 5, (0, 0, 255), -1)  # Red center
    return detected_objects

def match_objects_to_midpoints(detected_objects, midpoints):
    """Match each detected object center to the closest midpoint."""
    object_midpoint_map = []

    # Iterate over detected objects by color
    for color, objects in detected_objects.items():
        for obj in objects:
            obj_center = obj['center']
            closest_midpoint_idx = None
            min_distance = float('inf')

            # Iterate through the midpoints to find the closest one
            for i, midpoint in enumerate(midpoints):
                distance = calculate_distance(obj_center, midpoint)
                if distance < min_distance:
                    min_distance = distance
                    closest_midpoint_idx = i

            # Append the result as a dictionary with object details and matched midpoint index
            #     'object_center': obj_center,
            #     'closest_midpoint': midpoints[closest_midpoint_idx] if closest_midpoint_idx is not None else None
            object_midpoint_map.append({
                'object_color': color,
                'closest_midpoint_index': closest_midpoint_idx,
            })

    return object_midpoint_map

def calculate_distance(point1, point2):
    """Calculate Euclidean distance between two points."""
    return np.sqrt((point1[0] - point2[0]) ** 2 + (point1[1] - point2[1]) ** 2)

def detect_screw_location(image):
    # Define color ranges in HSV
    color_ranges = {
        'Screw_orange': (np.array([10, 45, 140]), np.array([25, 160, 200])),  # Orange range for screw
        'Screw_blue': (np.array([100, 110, 60]), np.array([120, 185, 120])),
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
            if 50 < cv2.contourArea(contour) < 100:  # Filter by area
                # Get the bounding box and centroid
                x_contour, y_contour, w_contour, h_contour = cv2.boundingRect(contour)

                # Adjust the center coordinates back to the full image
                adjusted_center_x = x_contour + w_contour // 2 + x  # add x from ROI
                adjusted_center_y = y_contour + h_contour // 2 + y  # add y from ROI
                center = (adjusted_center_x, adjusted_center_y)

                # Append detected object details
                detected_screw[color].append({
                    'contour': contour,
                    'bounding_box': (x_contour, y_contour, w_contour, h_contour),
                    'center': center
                })
                cv2.rectangle(image, (x_contour, y_contour), (x_contour + w_contour, y_contour + h_contour), (255, 0, 0), 2)
    return detected_screw

def calculate_relative_angle(screw_center_orange, screw_center_neon, dx1, dy1):
    angle_between_lines = None
    if screw_center_orange and screw_center_neon:
        # Calculate the direction vector for the line connecting the screw centers
        dx2, dy2 = screw_center_neon[0] - screw_center_orange[0], screw_center_neon[1] - screw_center_orange[1]

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
        print("Error: Could not find centers for 'Screw_orange' or 'neon'.")

    return angle_between_lines

def depth_image_process(point0, point_ref, scaling_factor):
    relative_vector = []
    # depth_stream = profile.get_stream(rs.stream.depth).as_video_stream_profile()
    # intrinsics = depth_stream.get_intrinsics()
    # intrinsics = rs.intrinsics()

    # Retrieve depth values at these points in meters
    # d1 = depth_frame.get_distance(point0[0], point0[1])
    # d2 = depth_frame.get_distance(point_ref[0], point_ref[1])
    # d_center = depth_frame.get_distance(int(intrinsics.ppx), int(intrinsics.ppy))

    # d1 = 1.02
    # d2 = 1.04

    pixel_distance_p0_screw = (math.sqrt((point_ref[0] - point0[0])**2 + (point_ref[1] - point0[1])**2)) * scaling_factor
    relative__pixel_vector = [point0[0] - point_ref[0],  # X component
                        point0[1] - point_ref[1]]  # Y component

    relative_vector = [relative__pixel_vector[0] * scaling_factor, relative__pixel_vector[1] * scaling_factor, 0.0]

    # if d1 == 0 or d2 == 0:
    #     print("Invalid depth values at one or both points.")
    # else:
    #     point_3d = rs.rs2_deproject_pixel_to_point(intrinsics, [int(point0[0]), int(point0[1])], d1)
    #     point_3d_ref = rs.rs2_deproject_pixel_to_point(intrinsics, [int(point_ref[0]), int(point_ref[1])], d2)

    #     distance = math.sqrt((point_3d_ref[0] - point_3d[0])**2 + (point_3d_ref[1] - point_3d[1])**2 + (point_3d_ref[2] - point_3d[2])**2)
    #     print("Distance between points:", distance, "meters")

    #     # Compute the position vector relative to the reference object
    #     relative_vector = [point_3d[0] - point_3d_ref[0],  # X component
    #                         point_3d[1] - point_3d_ref[1],  # Y component
    #                         point_3d[2] - point_3d_ref[2]]   # Z component
    return relative_vector

def display_hsv_image(image, roi):
    # Crop the image to the ROI
    x, y, w, h = roi
    # roi_image = image[y:y+h, x:x+w]

    # Convert the cropped ROI to HSV
    hsv_roi = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Split the channels for visualization
    h, s, v = cv2.split(hsv_roi)

    # Display each channel #................................................................
    # plt.imshow( h)
    # plt.show()
    # plt.imshow( s)
    # plt.show()
    # plt.imshow( v)
    # plt.show()

def vector_changed(new_vector, old_vector, tolerance=5.0):
    # A function to check if the relative vector has changed significantly

    return any(abs(n - o) > tolerance for n, o in zip(new_vector, old_vector))

def main():
    # image_path = r"C:\Users\oscik559\ONEDRI~1\RESEAR~1\SANJAY~1\holder\FOLDER~2.PNG"  # Replace with the path to your image file
    # image_path = r"C:\Users\oscik559\ONEDRI~1\RESEAR~1\SANJAY~1\holder\FOLDER~2.PNG"
    image_path = r"C:\Users\oscik559\Projects\USER_P~1\CAMERA~1\HOLDER\FOLDER~1.PNG"

    wait_key = 2000  # Time to wait for a keypress in milliseconds
    process_image(image_path, wait_key)

if __name__ == "__main__":
    main()
















