from pydantic import BaseModel, EmailStr
from typing import List, Optional

# --- Auth Schemas ---
class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    
class Token(BaseModel):
    access_token: str
    token_type: str
    
class TokenData(BaseModel):
    email: str | None = None

# --- Stress Assessment Schemas ---
class StressAnswers(BaseModel):
    answers: List[int] # e.g. [1, 2, 3, 4, 1] representing scores from questions

class StressResult(BaseModel):
    score: int
    level: str
    feedback: str

# --- Journal Schemas ---
class JournalEntry(BaseModel):
    text: str

class JournalAnalysis(BaseModel):
    summary: str
    mood: str
    stress_level: int
    key_issues: List[str]
    suggestions: List[str]
    motivation_message: str

# --- Planner Schemas ---
class PlannerRequest(BaseModel):
    goals: List[str]
    max_hours_per_day: int = 8

class PlannerResponse(BaseModel):
    plan: str # structured markdown string or json from AI
