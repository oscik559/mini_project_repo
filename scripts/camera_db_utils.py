# # camera_db_utils.py


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
    # First, see if a row for this object_name exists
    query = "SELECT object_id FROM camera_vision WHERE object_name = ?"
    db_handler.cursor.execute(query, (object_name,))
    result = db_handler.cursor.fetchone()

    if result is None:
        # No existing record; insert a new row
        insert_query = """
            INSERT INTO camera_vision
            (object_name, object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name, last_detected)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now','localtime'))
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
            SET object_color = ?,
                color_code = ?,
                pos_x = ?,
                pos_y = ?,
                pos_z = ?,
                rot_x = ?,
                rot_y = ?,
                rot_z = ?,
                usd_name = ?,
                last_detected = datetime('now','localtime')
            WHERE object_name = ?
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


def cleanup_camera_vision_records(db_handler, active_object_names):
    """
    Deletes any rows from camera_vision whose object_name is not in the active list.
    """
    # Build the query with the correct number of placeholders
    placeholders = ",".join(["?"] * len(active_object_names))
    delete_query = (
        f"DELETE FROM camera_vision WHERE object_name NOT IN ({placeholders})"
    )
    db_handler.cursor.execute(delete_query, active_object_names)
    db_handler.conn.commit()
