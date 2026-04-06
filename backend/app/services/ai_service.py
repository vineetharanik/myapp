from openai import OpenAI
from app.core.config import settings


def get_client():
    return OpenAI(api_key=settings.OPENAI_API_KEY)


import json

def analyze_journal(text: str) -> dict:
    client = get_client()

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        response_format={ "type": "json_object" },
        messages=[
            {"role": "system", "content": "You are a mental wellness and academic performance assistant. Always return your response in strict JSON format."},
            {"role": "user", "content": f"""
Analyze this user's journal entry and return ONLY a single JSON object with the following structure:
{{
  "summary": "short summary of user emotional state and activities",
  "mood": "positive | neutral | negative | stressed | motivated",
  "stress_level": <integer between 0 and 100>,
  "burnout_risk": <integer between 0 and 100>,
  "key_issues": ["list of detected problems"],
  "suggestions": ["actionable improvement steps"],
  "motivation_message": "short encouraging message",
  "skills_mentioned": ["list of academic/technical skills mentioned"],
  "skills_progress": {{"skill_name": "percentage_complete", ...}},
  "study_time_analysis": {{
    "actual_hours": <estimated study hours>,
    "focus_quality": "high | medium | low",
    "distractions": ["list of detected distractions"]
  }},
  "weekly_recommendations": {{
    "study_adjustments": ["recommendations for study schedule"],
    "wellness_tips": ["mental health recommendations"],
    "skill_focus": ["skills to prioritize this week"]
  }}
}}

Journal Entry:
{text}
"""}
        ]
    )

    try:
        result_text = response.choices[0].message.content
        return json.loads(result_text)
    except Exception as e:
        print("AI ERROR:", str(e))
        return {
            "summary": "AI temporarily unavailable",
            "mood": "neutral",
            "stress_level": 0,
            "burnout_risk": 0,
            "key_issues": [],
            "suggestions": ["Try again later"],
            "motivation_message": "Keep going, you're doing fine.",
            "skills_mentioned": [],
            "skills_progress": {},
            "study_time_analysis": {
                "actual_hours": 0,
                "focus_quality": "medium",
                "distractions": []
            },
            "weekly_recommendations": {
                "study_adjustments": [],
                "wellness_tips": [],
                "skill_focus": []
            }
        }


def generate_plan(goal: str, hours: int):
    client = get_client()

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a productivity coach."},
            {"role": "user", "content": f"""
Create a weekly study plan.

Goal: {goal}
Study hours per day: {hours}
"""}
        ]
    )

    return response.choices[0].message.content