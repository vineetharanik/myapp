from fastapi import APIRouter, Depends
from app.services.ai_service import generate_plan
from app.models.schemas import PlannerRequest
from app.api.dependencies import get_current_user

router = APIRouter()

@router.post("/generate")
def generate(data: PlannerRequest, current_user: dict = Depends(get_current_user)):
    # Depending on input spec, using "goal" and "hours"
    goal = ", ".join(data.goals) if data.goals else "General Study Focus"
    hours = data.max_hours_per_day
    result = generate_plan(goal, hours)
    return {"plan": result}
