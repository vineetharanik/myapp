import google.generativeai as genai
from app.core.config import settings
import json
import os

def get_client():
    """Initialize Google Gemini AI client"""
    api_key = settings.OPENAI_API_KEY  # Reusing this field for Google API key
    genai.configure(api_key=api_key)
    return genai.GenerativeModel('gemini-2.0-flash')

def analyze_journal(text: str) -> dict:
    """Analyze journal entry using Google Gemini AI"""
    try:
        model = get_client()
        
        prompt = f"""
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

Respond ONLY with valid JSON, no additional text.
"""

        response = model.generate_content(prompt)
        result_text = response.text
        
        # Clean up the response to extract JSON
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].strip()
        
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
    """Generate weekly study plan using Google Gemini AI"""
    try:
        model = get_client()
        
        prompt = f"""
Create a weekly study plan using Google Calendar format.

Goal: {goal}
Study hours per day: {hours}

Return a structured plan with:
- Daily breakdown
- Specific topics
- Time allocations
- Break recommendations
Format as clear, actionable text.
"""

        response = model.generate_content(prompt)
        return response.text
        
    except Exception as e:
        print("Plan Generation Error:", str(e))
        return "Weekly plan temporarily unavailable. Please try again later."

def generate_skill_roadmap(skill_name: str, current_level: str = "beginner", goals: str = "") -> dict:
    """Generate skill roadmap using Google Gemini AI"""
    try:
        model = get_client()
        
        prompt = f"""
Generate a comprehensive learning roadmap for {skill_name}.

Current level: {current_level}
Goals: {goals}

Return ONLY a JSON object with:
{{
  "skill_name": "{skill_name}",
  "current_level": "{current_level}",
  "estimated_duration": "X months",
  "difficulty": "beginner|intermediate|advanced",
  "prerequisites": ["list of prerequisites"],
  "milestones": [
    {{
      "phase": "Phase 1: Foundation",
      "duration_weeks": 4,
      "topics": ["topic1", "topic2", "topic3"],
      "projects": ["project1", "project2"],
      "resources": ["resource1", "resource2"],
      "assessment": "how to assess completion"
    }}
  ],
  "weekly_schedule": {{
    "theory_hours": 10,
    "practice_hours": 15,
    "project_hours": 5,
    "review_hours": 2
  }},
  "career_paths": ["career1", "career2", "career3"],
  "salary_range": "$X-$Y",
  "next_steps": ["what to learn after this skill"]
}}

Respond ONLY with valid JSON.
"""

        response = model.generate_content(prompt)
        result_text = response.text
        
        # Clean up the response to extract JSON
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].strip()
        
        return json.loads(result_text)
        
    except Exception as e:
        print("Roadmap Generation Error:", str(e))
        return {
            "skill_name": skill_name,
            "current_level": current_level,
            "error": "Failed to generate roadmap",
            "estimated_duration": "3-6 months",
            "milestones": [
                {
                    "phase": "Foundation",
                    "duration_weeks": 4,
                    "topics": ["Basic concepts", "Core fundamentals"],
                    "projects": ["Starter project"],
                    "resources": ["Online documentation", "Video tutorials"],
                    "assessment": "Complete basic exercises"
                }
            ]
        }

def generate_weekly_plan(user_skills: list, study_hours: int, stress_level: int = 50) -> dict:
    """Generate personalized weekly study plan using Google Gemini AI"""
    try:
        model = get_client()
        
        prompt = f"""
Create a balanced weekly study plan considering:
- Skills: {', '.join(user_skills)}
- Available study hours: {study_hours} hours/day
- Current stress level: {stress_level}%

Return ONLY a JSON object with:
{{
  "week_focus": "main focus for this week",
  "daily_schedule": {{
    "monday": {{"topics": ["topic1", "topic2"], "hours": 8, "breaks": ["10:30", "14:30"], "wellness_tip": "tip"}},
    "tuesday": {{"topics": ["topic1"], "hours": 8, "breaks": ["10:30", "14:30"], "wellness_tip": "tip"}},
    "wednesday": {{"topics": ["topic2", "practice"], "hours": 8, "breaks": ["10:30", "14:30"], "wellness_tip": "tip"}},
    "thursday": {{"topics": ["review", "project"], "hours": 8, "breaks": ["10:30", "14:30"], "wellness_tip": "tip"}},
    "friday": {{"topics": ["practice", "project"], "hours": 8, "breaks": ["10:30", "14:30"], "wellness_tip": "tip"}},
    "saturday": {{"topics": ["review", "light study"], "hours": 4, "breaks": ["11:00"], "wellness_tip": "tip"}},
    "sunday": {{"topics": ["rest", "planning"], "hours": 2, "breaks": [], "wellness_tip": "tip"}}
  }},
  "weekly_goals": ["goal1", "goal2", "goal3"],
  "stress_management": {{
    "daily_meditation": true,
    "exercise_recommendations": ["recommendation1", "recommendation2"],
    "break_reminders": ["reminder1", "reminder2"],
    "stress_reduction_techniques": ["technique1", "technique2"]
  }},
  "projects": [
    {{"name": "project1", "deadline": "end of week", "complexity": "medium"}}
  ],
  "resources": ["resource1", "resource2", "resource3"]
}}

Respond ONLY with valid JSON.
"""

        response = model.generate_content(prompt)
        result_text = response.text
        
        # Clean up the response to extract JSON
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        elif "```" in result_text:
            result_text = result_text.split("```")[1].strip()
        
        return json.loads(result_text)
        
    except Exception as e:
        print("Weekly Plan Generation Error:", str(e))
        return {
            "week_focus": "Skill development",
            "daily_schedule": {
                "monday": {"topics": ["Study main skill"], "hours": study_hours, "breaks": ["10:30", "14:30"], "wellness_tip": "Take regular breaks"},
                "tuesday": {"topics": ["Practice"], "hours": study_hours, "breaks": ["10:30", "14:30"], "wellness_tip": "Stay hydrated"},
                "wednesday": {"topics": ["Review"], "hours": study_hours, "breaks": ["10:30", "14:30"], "wellness_tip": "Stretch regularly"},
                "thursday": {"topics": ["Project work"], "hours": study_hours, "breaks": ["10:30", "14:30"], "wellness_tip": "Good posture"},
                "friday": {"topics": ["Assessment"], "hours": study_hours, "breaks": ["10:30", "14:30"], "wellness_tip": "Deep breathing"},
                "saturday": {"topics": ["Light review"], "hours": study_hours//2, "breaks": ["11:00"], "wellness_tip": "Relax and recharge"},
                "sunday": {"topics": ["Rest"], "hours": 2, "breaks": [], "wellness_tip": "Complete rest day"}
            },
            "weekly_goals": ["Complete weekly modules", "Practice exercises", "Review progress"],
            "stress_management": {
                "daily_meditation": True,
                "exercise_recommendations": ["15 min walk", "Stretching"],
                "break_reminders": ["Every hour", "Eye rest"],
                "stress_reduction_techniques": ["Deep breathing", "Progressive muscle relaxation"]
            }
        }
