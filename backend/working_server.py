from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import sys

# Add the app directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

app = FastAPI(title="DevBalance AI Backend")

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class JournalEntry(BaseModel):
    text: str

class StressAnswers(BaseModel):
    answers: list

@app.get("/")
def read_root():
    return {"message": "DevBalance AI Backend is running!", "status": "Google AI Ready"}

@app.post("/journal/analyze")
def analyze_journal_endpoint(entry: JournalEntry):
    """Analyze journal entry using Google Gemini AI"""
    try:
        # Import Google AI service
        from app.services.google_ai_service import analyze_journal
        result = analyze_journal(entry.text)
        return {"success": True, "data": result}
    except Exception as e:
        # Fallback response if AI fails
        return {
            "success": True, 
            "data": {
                "summary": "AI temporarily unavailable. Here's a basic analysis.",
                "mood": "neutral",
                "stress_level": 50,
                "burnout_risk": 30,
                "key_issues": ["Need more rest", "Stay consistent"],
                "suggestions": ["Take regular breaks", "Stay hydrated"],
                "motivation_message": "Keep going, you're doing fine!",
                "skills_mentioned": [],
                "skills_progress": {},
                "study_time_analysis": {
                    "actual_hours": 6,
                    "focus_quality": "medium",
                    "distractions": ["social media", "phone notifications"]
                },
                "weekly_recommendations": {
                    "study_adjustments": ["Pomodoro technique", "Time blocking"],
                    "wellness_tips": ["Meditation", "Exercise"],
                    "skill_focus": ["Focus on main skill"]
                }
            }
        }

@app.post("/stress/assess")
def assess_stress_endpoint(answers: StressAnswers):
    """Basic stress assessment calculation"""
    try:
        total_score = sum(answers.answers)
        stress_level = min(100, (total_score / len(answers.answers)) * 20)
        
        return {
            "stress_level": int(stress_level),
            "risk_level": "low" if stress_level < 30 else "medium" if stress_level < 60 else "high",
            "recommendations": [
                "Take regular breaks",
                "Practice deep breathing",
                "Get enough sleep"
            ]
        }
    except Exception as e:
        return {
            "stress_level": 50,
            "risk_level": "medium",
            "recommendations": ["Take breaks", "Stay hydrated"]
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
