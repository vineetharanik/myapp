from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import os
import sys

# Add app directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

app = FastAPI(title="DevBalance AI Enhanced Backend")

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enhanced Pydantic models
class JournalEntry(BaseModel):
    text: str
    study_hours: Optional[float] = None
    dsa_problems_solved: Optional[int] = 0
    dsa_platform: Optional[str] = None
    web_goal: Optional[str] = None
    mood_before: Optional[str] = None
    mood_after: Optional[str] = None
    energy_level: Optional[int] = None
    distractions: Optional[List[str]] = []
    achievements: Optional[List[str]] = []

class EnhancedJournalAnalysis(BaseModel):
    # Basic analysis
    summary: str
    mood: str
    stress_level: int
    burnout_risk: int
    
    # Enhanced features
    grammar_corrected_text: str
    writing_quality_score: int  # 1-100
    productivity_score: int  # 1-100
    focus_quality: str  # high, medium, low
    
    # Skills and DSA tracking
    skills_mentioned: List[str]
    skills_progress: Dict[str, float]
    dsa_alignment: str  # high, medium, low
    problems_solved_today: int
    learning_efficiency: float
    
    # Daily breakdown
    day_rating: str  # productive, average, poor
    recommendations: List[str]
    action_items: List[str]
    
    # Time tracking
    study_hours_actual: float
    study_hours_goal: float
    study_efficiency: float

# In-memory storage
journal_history: List[EnhancedJournalAnalysis] = []

def analyze_text_quality(text: str) -> Dict[str, Any]:
    """Analyze text quality, grammar, and structure"""
    word_count = len(text.split())
    sentence_count = text.count('.') + text.count('!') + text.count('?')
    
    # Basic grammar checks
    grammar_issues = []
    if text.islower():
        grammar_issues.append("Missing capitalization")
    if word_count < 10:
        grammar_issues.append("Too short - add more details")
    if "i" in text.lower() and "I" not in text:
        grammar_issues.append("Capitalization issues")
    
    writing_quality = max(20, 100 - len(grammar_issues) * 5)
    
    return {
        "grammar_corrected": text.replace("i", "I").capitalize(),
        "grammar_issues": grammar_issues,
        "writing_quality_score": writing_quality,
        "word_count": word_count,
        "sentence_count": sentence_count
    }

def calculate_burnout_risk(entry: JournalEntry) -> int:
    """Calculate comprehensive burnout risk"""
    risk_score = 0
    
    # Study hours factor
    if entry.study_hours and entry.study_hours > 10:
        risk_score += 20
    elif entry.study_hours and entry.study_hours > 8:
        risk_score += 10
    
    # DSA problems factor
    if entry.dsa_problems_solved and entry.dsa_problems_solved > 5:
        risk_score -= 10  # High productivity reduces burnout
    elif entry.dsa_problems_solved == 0:
        risk_score += 15
    
    # Mood factor
    mood_risk = {
        "stressed": 25,
        "anxious": 20,
        "tired": 15,
        "overwhelmed": 30,
        "motivated": -10,
        "excited": -15,
        "neutral": 5
    }
    risk_score += mood_risk.get(entry.mood_before.lower(), 10)
    
    # Energy level factor
    if entry.energy_level:
        if entry.energy_level < 3:
            risk_score += 15
        elif entry.energy_level > 8:
            risk_score -= 10
    
    # Distractions factor
    if entry.distractions and len(entry.distractions) > 3:
        risk_score += 10
    
    return min(100, max(0, risk_score))

def analyze_skills_alignment(text: str, dsa_platform: str, problems_solved: int) -> Dict[str, Any]:
    """Analyze skills mentioned and alignment with DSA practice"""
    common_skills = [
        "python", "javascript", "java", "cpp", "data structures", "algorithms",
        "react", "nodejs", "html", "css", "sql", "git", "docker",
        "machine learning", "ai", "web development", "mobile development"
    ]
    
    skills_mentioned = []
    for skill in common_skills:
        if skill.lower() in text.lower():
            skills_mentioned.append(skill)
    
    # Calculate alignment based on DSA practice
    alignment_score = 0
    if problems_solved > 0:
        alignment_score += 30
    if dsa_platform and any(platform in text.lower() for platform in ["leetcode", "codeforces", "hackerrank"]):
        alignment_score += 20
    
    alignment_level = "high" if alignment_score > 40 else "medium" if alignment_score > 20 else "low"
    
    skills_progress = {}
    for skill in skills_mentioned:
        base_progress = 50 + (problems_solved * 5)
        skills_progress[skill] = min(100, base_progress)
    
    return {
        "skills_mentioned": skills_mentioned,
        "skills_progress": skills_progress,
        "dsa_alignment": alignment_level,
        "alignment_score": alignment_score
    }

def generate_ai_analysis(entry: JournalEntry) -> EnhancedJournalAnalysis:
    """Generate comprehensive AI analysis with grammar correction and insights"""
    text_analysis = analyze_text_quality(entry.text)
    burnout_risk = calculate_burnout_risk(entry)
    skills_analysis = analyze_skills_alignment(entry.text, entry.dsa_platform or "", entry.dsa_problems_solved)
    
    # Calculate productivity scores
    productivity_score = 50
    if entry.dsa_problems_solved > 0:
        productivity_score += entry.dsa_problems_solved * 3
    if entry.study_hours and entry.study_hours > 0:
        productivity_score += min(20, entry.study_hours * 2)
    
    learning_efficiency = 0.0
    if entry.dsa_problems_solved > 0 and entry.study_hours:
        learning_efficiency = entry.dsa_problems_solved / entry.study_hours
    
    # Generate recommendations
    recommendations = []
    if burnout_risk > 70:
        recommendations.extend([
            "🚨 High burnout risk detected!",
            "Take immediate rest day tomorrow",
            "Reduce study hours to 6-8 hours",
            "Practice relaxation techniques"
        ])
    elif entry.dsa_problems_solved == 0:
        recommendations.extend([
            "🎯 Start with easy DSA problems",
            "Focus on understanding concepts",
            "Use visualization techniques"
        ])
    else:
        recommendations.extend([
            "🔥 Great problem-solving today!",
            "Maintain consistent practice",
            "Document your solutions"
        ])
    
    # Determine day rating
    if productivity_score > 80:
        day_rating = "productive"
    elif productivity_score > 50:
        day_rating = "average"
    else:
        day_rating = "poor"
    
    return EnhancedJournalAnalysis(
        # Basic analysis
        summary=f"Day {day_rating}: {text_analysis['word_count']} words recorded. {entry.dsa_problems_solved} DSA problems solved.",
        mood=entry.mood_after or entry.mood_before or "neutral",
        stress_level=min(100, burnout_risk),
        burnout_risk=burnout_risk,
        
        # Enhanced features
        grammar_corrected_text=text_analysis['grammar_corrected'],
        writing_quality_score=text_analysis['writing_quality_score'],
        productivity_score=productivity_score,
        focus_quality="high" if learning_efficiency > 2 else "medium" if learning_efficiency > 1 else "low",
        
        # Skills and DSA
        skills_mentioned=skills_analysis['skills_mentioned'],
        skills_progress=skills_analysis['skills_progress'],
        dsa_alignment=skills_analysis['dsa_alignment'],
        problems_solved_today=entry.dsa_problems_solved,
        learning_efficiency=learning_efficiency,
        
        # Daily breakdown
        day_rating=day_rating,
        recommendations=recommendations,
        action_items=[
            f"Practice {len(skills_analysis['skills_mentioned'])} skills mentioned",
            f"Maintain {learning_efficiency:.1f} problems/hour efficiency",
            f"Keep burnout risk below {burnout_risk + 10}%"
        ],
        
        # Time tracking
        study_hours_actual=entry.study_hours or 0,
        study_hours_goal=8.0,
        study_efficiency=min(150, (entry.study_hours or 0) / 8.0 * 100)
    )

@app.get("/")
def read_root():
    return {
        "message": "DevBalance AI Enhanced Backend", 
        "status": "Ready with AI analysis",
        "features": ["Grammar correction", "Burnout calculation", "Skills tracking", "DSA alignment"]
    }

@app.post("/journal/enhanced-analyze", response_model=EnhancedJournalAnalysis)
def enhanced_analyze_journal(entry: JournalEntry):
    """Enhanced journal analysis with AI-powered insights"""
    try:
        analysis = generate_ai_analysis(entry)
        
        # Store in history
        journal_history.append(analysis)
        
        return analysis
        
    except Exception as e:
        raise Exception(f"Analysis failed: {str(e)}")

@app.get("/journal/history", response_model=List[EnhancedJournalAnalysis])
def get_journal_history():
    """Get all enhanced journal analyses"""
    return journal_history

@app.post("/journal/quick-entry", response_model=EnhancedJournalAnalysis)
def quick_journal_entry(text: str, mood: str, study_hours: float = 0.0):
    """Quick journal entry for simple text input"""
    entry = JournalEntry(
        text=text,
        mood_before=mood,
        mood_after=mood,
        study_hours=study_hours
    )
    return enhanced_analyze_journal(entry)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
