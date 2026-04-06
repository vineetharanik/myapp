import uuid
from typing import Optional

# In-memory mock database
# Maps collection name to a dictionary of records
db = {
    "users": {},
    "journals": {}
}

class DBService:
    @staticmethod
    def add_user(user_data: dict) -> dict:
        user_id = str(uuid.uuid4())
        user_data["id"] = user_id
        db["users"][user_data["email"]] = user_data # Using email as fast lookup key
        return user_data

    @staticmethod
    def get_user_by_email(email: str) -> Optional[dict]:
        return db["users"].get(email)

    @staticmethod
    def save_journal(user_email: str, entry: str, analysis: dict):
        journal_id = str(uuid.uuid4())
        record = {
            "id": journal_id,
            "user_email": user_email,
            "entry": entry,
            "analysis": analysis
        }
        db["journals"][journal_id] = record
        return record
