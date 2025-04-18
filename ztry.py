        restored_users = []

        for user in users:
            if "face_encoding" in user and isinstance(user["face_encoding"], str):
                user["face_encoding"] = psycopg2.Binary(
                    binascii.unhexlify(user["face_encoding"])
                )

            if "voice_embedding" in user and isinstance(user["voice_embedding"], str):
                user["voice_embedding"] = psycopg2.Binary(
                    binascii.unhexlify(user["voice_embedding"])
                )

            user.pop("user_id", None)

            placeholders = ", ".join(["%s"] * len(user))
            columns = ", ".join(user.keys())
            values = list(user.values())

            sql = f"""
            INSERT INTO users ({columns}) VALUES ({placeholders})
            ON CONFLICT (liu_id) DO UPDATE SET
                face_encoding = EXCLUDED.face_encoding,
                voice_embedding = EXCLUDED.voice_embedding,
                preferences = EXCLUDED.preferences,
                profile_image_path = EXCLUDED.profile_image_path,
                interaction_memory = EXCLUDED.interaction_memory,
                last_updated = CURRENT_TIMESTAMP
            """

            self.cursor.execute(sql, values)
            restored_users.append(user["liu_id"])  # ✅ Collect ID instead of logging every one

        self.conn.commit()

        # ✅ One neat log line:
        logger.info(f"✅ Restored {len(restored_users)} user(s): {', '.join(restored_users)}")
