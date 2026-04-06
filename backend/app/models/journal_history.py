from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class JournalEntryWithTimestamp(BaseModel):
    text: str
    timestamp: datetime = None
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat() if v else None
        }

class JournalAnalysisWithTimestamp(BaseModel):
    summary: str
    mood: str
    stress_level: int
    key_issues: List[str]
    suggestions: List[str]
    motivation_message: str
    timestamp: datetime = None
    original_text: str = None
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat() if v else None
        }
