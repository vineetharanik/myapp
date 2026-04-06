from fastapi import APIRouter, Depends
from app.models.schemas import StressAnswers, StressResult
from app.api.dependencies import get_current_user

router = APIRouter()

@router.post("/assess", response_model=StressResult)
def assess_stress(request: StressAnswers, current_user: dict = Depends(get_current_user)):
    # Very basic static stress calculation for V1
    # Assumes answers are integers ranging from 1 to 5
    score = sum(request.answers)
    max_score = len(request.answers) * 5
    
    percentage = (score / max_score) * 100 if max_score > 0 else 0
    
    level = "Low"
    feedback = "You are doing well, keep up the balanced lifestyle."
    
    if percentage > 70:
        level = "High"
        feedback = "You show signs of high stress. Please consider taking a break or consulting a professional."
    elif percentage > 40:
        level = "Medium"
        feedback = "You have some stress. Finding time to relax could be beneficial."
        
    return StressResult(score=score, level=level, feedback=feedback)
