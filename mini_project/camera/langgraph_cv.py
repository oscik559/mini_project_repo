import cv2
import numpy as np
from langgraph.graph import StateGraph, END
from typing import Dict, Any, TypedDict, List, Tuple
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import pyrealsense2 as rs
import time
from collections import defaultdict
import os
import psycopg2
import logging
from typing_extensions import TypedDict
import math

logger = logging.getLogger("ShapeDetection")

### STATE SCHEMA ###
class SlideInfo(TypedDict):
    bbox: Tuple[int, int, int, int]
    color: str
    center: Tuple[float, float]
    angle: float

class VisionState(TypedDict, total=False):
    input: str
    image: Any
    roi: str
    target: str
    return_: List[str]
    tray: Dict[str, Any]
    tray_mask: Any
    tray_contour: Any
    tray_detected: Any
    shape_detected: Any
    slides: List[Any]
    slide_infos: List[SlideInfo]
    screw_position: List[Any]
    scaling_factor: Any
    orange_screwpos: Any

def classify_color_hsv(hsv):
    h, s, v = hsv
    if s < 40 and v < 50:
        return "black"
    elif h < 15 or h > 160:
        return "red"
    elif 15 <= h <= 35:
        return "yellow"
    elif 35 < h <= 85:
        return "green"
    elif 85 < h <= 130:
        return "blue"
    else:
        return "unknown"
    
def calculate_slide_idx(image, tray_mask, tray_contour, all_slides):
    rect = cv2.minAreaRect(tray_contour) 
    x, y, w, h = cv2.boundingRect(tray_contour)
    box = cv2.boxPoints(rect).astype(np.int64)
    hsv_roi = cv2.cvtColor(image[y : y + h, x : x + w], cv2.COLOR_BGR2HSV)
    red_mask = cv2.inRange(hsv_roi, np.array([0, 70, 50]), np.array([10, 255, 255])) + cv2.inRange(hsv_roi, np.array([170, 70, 50]), np.array([180, 255, 255]))
    for red_contour in cv2.findContours(red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]:
        if cv2.contourArea(red_contour) > 600:
            M = cv2.moments(red_contour)
            red_center = np.mean(cv2.boxPoints(cv2.minAreaRect(red_contour)), axis=0) + [x,y,]
            closest_idx = np.argmin([np.linalg.norm(corner - red_center) for corner in box])
            box_red = cv2.boxPoints(cv2.minAreaRect(red_contour)).astype(np.int64)
            pts_red = np.array([(box_red[0]) + (x, y),(box_red[1]) + (x, y),(box_red[2]) + (x, y),(box_red[3]) + (x, y),]).astype(np.int64)
            image = cv2.polylines(image, [pts_red], isClosed=True, color=(0, 0, 255), thickness=2)

            tray_points = [box[closest_idx]] # POINT 0
            next_idx = (closest_idx + 1) % 4
            prev_idx = (closest_idx - 1) % 4
            longer_corner_idx = (next_idx if np.linalg.norm(box[closest_idx] - box[next_idx]) > np.linalg.norm(box[closest_idx] - box[prev_idx]) else prev_idx)
            tray_points.append(box[longer_corner_idx]) # POINT 1
            remaining_indices = set(range(4)) - {closest_idx, longer_corner_idx}
            shorter_corner_idx = min(remaining_indices,key=lambda idx: np.linalg.norm(box[closest_idx] - box[idx]),)
            tray_points.append(box[shorter_corner_idx]) # POINT 2
            point3_idx = (set(range(4)) - {closest_idx, longer_corner_idx, shorter_corner_idx}).pop()
            tray_points.append(box[point3_idx]) # POINT 3
            # Draw tray points and labels
            for i, pt in enumerate(tray_points):
                cv2.circle(image, tuple(pt), 1, (0, 0, 255), -1)
                cv2.putText(image,f"point{i}",tuple(pt),cv2.FONT_HERSHEY_SIMPLEX,0.4,(255, 0, 0),2,)
            
            # Segmentation
            point0 = tray_points[0]
            point1 = tray_points[1]
            point2 = tray_points[2]
            point3 = tray_points[3]
            coordinates_top = []
            coordinates_bottom = []
            dx, dy = point1[0] - point0[0], point1[1] - point0[1]
            tray_angle_with_x_axis = 90 - math.degrees(math.atan2(dy, dx))
            coordinates_top.append((int(point0[0]), int(point0[1]))) # First segment for top
            coordinates_bottom.append((int(point2[0]), int(point2[1]))) # First segment for bottom
            for i in range(1, 10): 
                segment_ratio = i / 10
                segment_x = int(point0[0] + segment_ratio * (point1[0] - point0[0]))
                segment_y = int(point0[1] + segment_ratio * (point1[1] - point0[1]))

                # Calculate the corresponding points on the opposite edge (point2 to point3)                
                line_start = (segment_x, segment_y)
                line_end = (int(point2[0] + segment_ratio * (point3[0] - point2[0])),int(point2[1] + segment_ratio * (point3[1] - point2[1])),)

                # Draw vertical segmenting green line
                cv2.line(image, line_start, line_end, (0, 255, 0), 1)
                coordinates_top.append((segment_x, segment_y)) # Segmented parts for top part of tray
            coordinates_top.append((int(point1[0]), int(point1[1]))) # Last segment for top

            for i in range(1, 10 + 1):
                segment_ratio = i / 10
                segment_x = int(point2[0] + segment_ratio * (point3[0] - point2[0]))
                segment_y = int(point2[1] + segment_ratio * (point3[1] - point2[1]))
                coordinates_bottom.append((segment_x, segment_y))# Segmented parts for bottom part of tray
            coordinates_bottom.append((int(point3[0]), int(point3[1])))# Last segment for bottom
            
            merged_midpoints = calculate_midpoints_and_draw(image, coordinates_top) + calculate_midpoints_and_draw(image, coordinates_bottom)
            matched_slides = match_objects_to_midpoints(all_slides, merged_midpoints, image)
    return matched_slides, tray_angle_with_x_axis, point0

def calculate_midpoints_and_draw(image, coordinates, color=(0, 255, 0)):
    midpoints = []
    # Iterate through the coordinates list to calculate midpoints
    for i in range(len(coordinates) - 1):
        point1, point2 = coordinates[i], coordinates[i + 1]
        midpoint = ((point1[0] + point2[0]) // 2, (point1[1] + point2[1]) // 2)
        midpoints.append(midpoint)
        
        cv2.circle(image, midpoint, 5, color, -1) # Draw a circle at the midpoint
    return midpoints

def match_objects_to_midpoints(detected_objects, midpoints, image):
    object_midpoint_map = []
    # Iterate over detected objects by color
    for obj in detected_objects:
        obj_contour = obj["contour"]
        x_contour, y_contour, w_contour, h_contour = cv2.boundingRect(obj_contour)
        obj_center = (x_contour + w_contour // 2, y_contour + h_contour // 2)
        cv2.circle(image, obj_center, 5, (0,255,0), -1) # Draw a circle at the midpoint
        closest_midpoint_idx = None
        min_distance = float("inf")
        # Iterate through the midpoints to find the closest one
        for i, midpoint in enumerate(midpoints):
            distance = np.sqrt((obj_center[0] - midpoint[0]) ** 2 + (obj_center[1] - midpoint[1]) ** 2)                
            if distance < min_distance:
                min_distance = distance
                closest_midpoint_idx = i

        if closest_midpoint_idx < 10:
            slide_pos_x = (23.0 + (closest_midpoint_idx * 30.5))
            slide_pos_y = 46
            slide_pos_z = -19.6
        else:
            slide_pos_x = (23.0 + ((closest_midpoint_idx -10) * 30.5))
            slide_pos_y = 175
            slide_pos_z = -19.6
        object_midpoint_map.append({"contour": obj["contour"],"color": obj["color"],"shape": 'rectangle', "closest_midpoint_index": closest_midpoint_idx, "pos_X": slide_pos_x, "pos_Y": slide_pos_y, "pos_Z": slide_pos_z})
    return object_midpoint_map

def get_connection():
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        raise EnvironmentError("DATABASE_URL not found in .env")
    return psycopg2.connect(db_url)

def clear_old_camera_vision_records(conn, expiry_seconds=2):
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM camera_vision")
        conn.commit()
        logger.info("🧨 Deleted all camera_vision records for fresh session")
    except Exception as e:
        logger.error(f"❌ Failed to delete all camera_vision records: {e}")
        conn.rollback()

def get_usd_name(object_name):
    if object_name.startswith("slide_"):
        return "Slide.usd"
    elif object_name == "Fixture":
        return "Fixture.usd"
    elif object_name == "Slide_Holder":
        return "Slide_Holder.usd"
    elif object_name.startswith("circle_"):
        return "Cylinder.usd"
    elif object_name.startswith("rectangle_"):
        return "Cuboid.usd"
    elif object_name.startswith("square_"):
        return "Cube.usd"
    elif object_name.startswith("pentagon_"):
        return "Pentagon.usd"
    elif object_name.startswith("hexagon_"):
        return "Hexagon.usd"
    else:
        return "unknown"
    
def clear_db_function():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM camera_vision;")
        conn.commit()

    except Exception as e:
        print(f"Database error in cleanup_camera_vision_records: {e}")
        conn.rollback()

### NODE 1: Instruction Parser ###
def instruction_parser(state: Dict[str, Any]) -> Dict[str, Any]:
    instruction = state["input"][0]
    if any(word in instruction.lower() for word in ["tray", "slides"]):
        mode = "tray"
    else:
        mode = "shapes"
    return {
        **state,
        "roi": "tray" if mode == "tray" else "shapes",
        "target": "glass slides" if mode == "tray" else "contours",
        "return_": ["position", "orientation", "color"],
        "mode": mode
    }

### NODE 2: Screw_Position ###
def screw_position(state: Dict[str, Any]) -> Dict[str, Any]:
    image = state["image"]    
    screw_roi = image[50:-550, 350:-300]
    hsv = cv2.cvtColor(screw_roi, cv2.COLOR_BGR2HSV)
    screw_colors = {
        "orange": (np.array([9, 50, 50]), np.array([19, 255, 255])),
        "blue": (np.array([90, 50, 50]), np.array([140, 255, 255])),
    }
    screw_positions = []
    for color_name, (lower, upper) in screw_colors.items():
        mask = cv2.inRange(hsv, lower, upper)
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if not contours:
            continue
        largest = max(contours, key=cv2.contourArea)
        # M = cv2.moments(largest)
        x_contour, y_contour, w_contour, h_contour = cv2.boundingRect(largest)
        cX = x_contour + w_contour // 2 + 350
        cY = y_contour + h_contour // 2 + 50
        screw_pos = [cX, cY]

        screw_positions.append({"color": color_name, "screwpos": screw_pos})
        cv2.circle(image, (cX, cY), 5, (0, 140, 255), 2)

    # cv2.imshow("Table_ROI", screw_roi)
    state["screw_position"] = screw_positions
    positions = {item['color']: item['screwpos'] for item in state['screw_position']}
    orange_screwpos = positions.get('orange')
    blue_screwpos = positions.get('blue')
    if not orange_screwpos:
        orange_screwpos = [536,106]
    pixel_dist = np.linalg.norm(np.array(orange_screwpos[:2]) - np.array(blue_screwpos[:2]))
    state["scaling_factor"] = (250 / pixel_dist)
    state["orange_screwpos"] = orange_screwpos
    return state

### NODE 3: Tray Detector ###
def tray_detector(state: Dict[str, Any]) -> Dict[str, Any]:
    image = state["image"]
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edged = cv2.Canny(blurred, 50, 150)
    # cv2.imshow("canny_image", edged)

    contours, _ = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    area = []
    for cnt1 in contours:
        area = np.append(area, cv2.contourArea(cnt1))
    for cnt in contours:
        if 10000 > cv2.contourArea(cnt) > 5000 :
            rect = cv2.minAreaRect(cnt)
            box = cv2.boxPoints(rect).astype(int)
            cv2.drawContours(image, [box], -1, 255, -1)
            cv2.imshow("canny_image", image)

        if cv2.contourArea(cnt) > 50000:
            rect = cv2.minAreaRect(cnt)
            box = cv2.boxPoints(rect).astype(int)
            center = (np.array(rect[0]) - np.array(state["orange_screwpos"])) * state["scaling_factor"]
            center = np.append(center, 0)

            state["tray"] = {
                "box": box.tolist(),
                "center": center,
                "angle": rect[2] if rect[2] >= -45 else rect[2] + 90
            }
            state["tray_contour"] = cnt
            tray_mask = np.zeros_like(gray)
            cv2.drawContours(tray_mask, [box], -1, 255, -1)
            state["tray_detected"] = True
            state["tray_mask"] = tray_mask
            # cv2.imshow("contour image", tray_mask)
            return state
    
    
    state["tray_detected"] = False
    return state


def shape_detector(state: Dict[str, Any]) -> Dict[str, Any]:
    image = state["image"]
    clipped_image = image[80:-200, 300:-300]
    gray = cv2.cvtColor(clipped_image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (3, 3), 0)
    edged = cv2.Canny(blurred, 100, 200)

    contours, _ = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    mask = np.zeros_like(gray)
    all_shapes = []
    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area < 200 or area > 5000:
            continue
        
        epsilon = 0.035 * cv2.arcLength(cnt, True)
        approx = cv2.approxPolyDP(cnt, epsilon, True)
        if len(approx) == 3:
            shape_name, approx = "triangle", approx
        elif len(approx) == 4:
            x, y, w, h = cv2.boundingRect(approx)
            aspect_ratio = float(w) / h
            shape_name, approx = ("square" if 0.8 <= aspect_ratio <= 1.2 else "rectangle"), approx
        elif len(approx) == 5:
            shape_name, approx = "pentagon", approx
        elif len(approx) == 6:
            shape_name, approx = "hexagon", approx
        elif len(approx) > 6:
            shape_name, approx = "circle", approx
        else:
            shape_name, approx = "unknown", approx
            
        color_mask = np.zeros(clipped_image.shape[:2], dtype=np.uint8) 
        cv2.drawContours(color_mask, [cnt], -1, 255, thickness=cv2.FILLED)       
        mean_color = cv2.mean(clipped_image, mask=color_mask)
        avg_bgr = mean_color[:3]
        bgr_color = np.uint8([[avg_bgr]])  # Shape (1,1,3)
        hsv_color = cv2.cvtColor(bgr_color, cv2.COLOR_BGR2HSV)[0][0]
        color = classify_color_hsv(hsv_color)
        cnt_shifted = cnt + [300, 80]
        all_shapes.append({"shape": shape_name, "contour": cnt_shifted, "color": color})
        # cv2.imshow("Detected Slides", color_mask)
        # cv2.waitKey()

    if not all_shapes:
        state["shape_detected"] = False
    else:
        state["shape_detected"] = True
    state["slides"] = all_shapes
    return state

### NODE 5: Slide Detector ###
def slide_detector(state: Dict[str, Any]) -> Dict[str, Any]:
    # Convert the image to HSV color space
    
    color_ranges = {
        "green": [(30, 45, 80), (70, 160, 190)],  # Green hue range
        "orange": [(10, 90, 100), (25, 255, 255)],  # Orange hue range
        "pink": [(150, 120, 120), (175, 195, 165)],  # Pink hue range
        "white": [(0, 0, 200), (180, 25, 255)]  # White hue range
    }
    all_slides = []
    tray_mask = state["tray_mask"]
    masked_color = cv2.bitwise_and(state["image"], state["image"], mask=tray_mask)
    hsv_image = cv2.cvtColor(masked_color, cv2.COLOR_BGR2HSV)
    # Iterate over color ranges to find matching colored slides
    for color, (lower, upper) in color_ranges.items():
        color_mask = cv2.inRange(hsv_image, np.array(lower), np.array(upper))
        
        contours, _ = cv2.findContours(color_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        # slides = [cnt for cnt in contours if 200 < cv2.contourArea(cnt) < 500]
        # all_slides.extend(slides)
        
        
        for contour in contours:
            if 200 < cv2.contourArea(contour) < 500:
                x_contour, y_contour, w_contour, h_contour = cv2.boundingRect(contour)
                cv2.rectangle(masked_color,(x_contour, y_contour),(x_contour + w_contour, y_contour + h_contour),(255, 0, 0),2,)
                all_slides.append({"contour": contour, "color": color, "shape": 'rectangle'})

    all_slides_with_idx, tray_angle_with_x_axis, point0 = calculate_slide_idx(state["image"], tray_mask, state["tray_contour"], all_slides)
    state["tray"]["angle"] = tray_angle_with_x_axis
    center = (point0 - np.array(state["orange_screwpos"])) * state["scaling_factor"]
    center = np.append(center, 0) 


    state["tray"]["center"] = center / 10
    state["slides"] = all_slides_with_idx
    return state

### NODE 6: Color info Classifier ###
def color_info_classifier(state: Dict[str, Any]) -> Dict[str, Any]:
    slide_infos = []
    for cnt in state["slides"]:
        x, y, w, h = cv2.boundingRect(cnt["contour"])
        slide_infos.append({"shape": cnt["shape"], "bbox": (x, y, w, h), "color": cnt["color"]})
    state["slide_infos"] = slide_infos
    return state

### NODE 7: Pose Estimator ###
def pose_estimator(state: Dict[str, Any]) -> Dict[str, Any]:
    for info, cnt in zip(state["slide_infos"], state["slides"]):
        if state["roi"] == "tray":
            position = (cnt["pos_Y"], cnt["pos_X"], cnt["pos_Z"])
            info["center"] = position
            info["angleX"] = 0
            info["angleY"] = 0
            info["angleZ"] = 0
        else:
            rect = cv2.minAreaRect(cnt["contour"])
            relative_pixel_pos = (np.array(rect[0]) - np.array(state["orange_screwpos"])) * state["scaling_factor"]
            position = [relative_pixel_pos[0]/10 + 0.5, relative_pixel_pos[1]/10, 1.25]
            info["center"] = position
            angle = rect[2] if rect[2] >= -45 else rect[2] + 90
            info["angleX"] = 0
            info["angleY"] = 0
            info["angleZ"] = angle

    if state["roi"] == "tray":
        state["slide_infos"].append({"shape": 'tray', "bbox": state["tray"]["box"], "color": 'black', "center": state["tray"]["center"], "angleX": 180, "angleY": 0, "angleZ": state["tray"]["angle"]})
        state["slide_infos"].append({"shape": 'holder', "color": 'black', "center": [9,44,11], "angleX": 180, "angleY": 0, "angleZ": 0})
    return state

### NODE 8: Output Formatter ###
def output_formatter(state: Dict[str, Any]) -> Dict[str, Any]:
    slides = state["slide_infos"]
    named_slides = {}
    shape_counts = defaultdict(int)
    idx = 0
    conn = get_connection()
    clear_old_camera_vision_records(conn)

    try:
        cursor = conn.cursor()
        for idx, slide in enumerate(slides):
            if state["roi"] == "tray":
                if idx == len(slides) - 2:
                    slide_id = "Fixture"
                elif idx == len(slides) - 1:
                    slide_id = "Slide_Holder"
                else:
                    slide_id = f"slide_{idx + 1}"
            else:
                shape = slide["shape"]
                shape_counts[shape] += 1
                slide_id = f"{shape}_{shape_counts[shape]}"

            named_slides[slide_id] = {
                "position": [round(slide["center"][0], 2), round(slide["center"][1], 2)],
                "orientation": round(slide["angleZ"], 2),
                "color": slide["color"]
            }
    
            # Prepare values for DB
            object_name = slide_id
            object_color = slide["color"]
            color_code = [0, 0, 0]  # Placeholder, adjust if needed
            pos_x = float(round(slide["center"][0], 2))
            pos_y = float(round(slide["center"][1], 2))
            pos_z = float(round(slide["center"][2], 2))
            rot_x = float(round(slide["angleX"], 2))
            rot_y = float(round(slide["angleY"], 2))
            rot_z = float(round(slide["angleZ"], 2))
            usd_name = get_usd_name(object_name)

            cursor.execute("SELECT object_id FROM camera_vision WHERE object_name = %s", (object_name,))
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
                    (object_name, object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name,),)
                logger.info(f"➕ Inserted {object_name} into camera_vision")
            else:
                update_query = """
                    UPDATE camera_vision
                    SET object_color = %s, color_code = %s, pos_x = %s, pos_y = %s, pos_z = %s, rot_x = %s, rot_y = %s, rot_z = %s, usd_name = %s, last_detected = NOW() WHERE object_name = %s """
                cursor.execute(
                    update_query,
                    (object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name, object_name,),)
                logger.info(f"🔁 Updated {object_name} in camera_vision")
            conn.commit()

    except Exception as e:
        logger.error(f"Database error in output_formatter: {e}")
        conn.rollback()

    finally:
        conn.close()

    if state["roi"] == "tray":
        tray_info = state["tray"]
        return {
        "tray": {
            "center": [round(tray_info["center"][0], 2), round(tray_info["center"][1], 2)],
            "angle": round(tray_info["angle"], 2)
        },
        "slides": named_slides,
        "slide_count": idx}
    else:
        return {"slides": named_slides,"slide_count": idx}

### NODE 9: Output Formatter ###
def clear_db(state: Dict[str, Any]) -> Dict[str, Any]:
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM camera_vision;")
        conn.commit()

    except Exception as e:
        print(f"Database error in cleanup_camera_vision_records: {e}")
        conn.rollback()

### BUILD LANGGRAPH WORKFLOW ###
builder = StateGraph(VisionState)
builder.add_node("Parse", instruction_parser)
builder.add_node("Screwpos", screw_position)
builder.add_node("TrayDetect", tray_detector)
builder.add_node("ShapeDetect", shape_detector)
builder.add_node("SlideDetect", slide_detector)
builder.add_node("Classify", color_info_classifier)
builder.add_node("Pose", pose_estimator)
builder.add_node("Format", output_formatter)
builder.add_node("Cleardb", clear_db)

builder.set_entry_point("Parse")
builder.add_edge("Parse", "Screwpos")
builder.add_conditional_edges("Screwpos",lambda state: state["roi"] if state["roi"] else "none",
    {
        "tray": "TrayDetect",
        "shapes": "ShapeDetect",
        "none": END
    }
)
builder.add_conditional_edges("TrayDetect",lambda state: "proceed" if state["tray_detected"] else "not detected",
    {
        "proceed": "SlideDetect",   
        "not detected": "Cleardb" 
    }
)
builder.add_conditional_edges("ShapeDetect",lambda state: "proceed" if state["shape_detected"] else "not detected",
    {
        "proceed": "Classify",   
        "not detected": "Cleardb" 
    }
)
# builder.add_edge("ShapeDetect", "Classify")
builder.add_edge("SlideDetect", "Classify")
builder.add_edge("Classify", "Pose")
builder.add_edge("Pose", "Format")
builder.add_edge("Format", END)
builder.add_edge("Cleardb", END)

graph = builder.compile()
print(graph.get_graph().draw_mermaid())

### TEST EXECUTION ###
if __name__ == "__main__":
    conn = get_connection()
    pipeline = rs.pipeline()
    config = rs.config()
    config.enable_stream(rs.stream.color, 1280, 720, rs.format.bgr8, 30)
    pipeline.start(config)
    for _ in range(15): # Warm-up: drop first 30 frames to stabilize exposure and alignment
        pipeline.wait_for_frames()

    try:
        while True:
            frames = pipeline.wait_for_frames()
            color_frame = frames.get_color_frame()
            if not color_frame:
                continue
            image = np.asanyarray(color_frame.get_data())
            # image = cv2.imread("1.png")
            cursor = conn.cursor()
            query = "SELECT description FROM operation_library WHERE trigger = TRUE;"
            cursor.execute(query)
            description = cursor.fetchone()
            operation_status_query = "SELECT operation_status FROM isaac_sim_gui WHERE gui_feature = 'Start';"
            cursor.execute(operation_status_query)
            (operation_status,) = cursor.fetchone()
            # description = ['tray']
            # operation_status = False
            if description != None and not operation_status:                
                result = graph.invoke({
                    "input": description,
                    "image": image
                },{"recursion_limit": 100})
            else:
                clear_db_function()
            time.sleep(3)

    finally:
        pipeline.stop()