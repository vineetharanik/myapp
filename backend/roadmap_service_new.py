from app.services.google_ai_service import generate_skill_roadmap, generate_weekly_plan
from datetime import datetime, timedelta
import json

def generate_skill_roadmap(skill_name: str, current_level: str = "beginner", goals: str = "") -> dict:
    """Generate a comprehensive skill roadmap using Google Gemini AI"""
    return generate_skill_roadmap(skill_name, current_level, goals)

def generate_weekly_plan(user_skills: list, study_hours: int, stress_level: int = 50) -> dict:
    """Generate personalized weekly study plan using Google Gemini AI"""
    return generate_weekly_plan(user_skills, study_hours, stress_level)

def analyze_skills_progress(journal_analyses: list, target_skills: list) -> dict:
    """Analyze skills progress based on journal entries using Google Gemini AI"""
    try:
        from app.services.google_ai_service import get_client
        
        # Extract relevant information from journal analyses
        journal_text = "\n".join([
            f"Entry: {analysis.get('summary', '')}\n"
            f"Skills mentioned: {analysis.get('skills_mentioned', [])}\n"
            f"Study time: {analysis.get('study_time_analysis', {})}\n"
            f"Suggestions: {analysis.get('suggestions', [])}"
            for analysis in journal_analyses
        ])

        model = get_client()
        
        prompt = f"""
Based on these journal entries, analyze the user's progress in their target skills.

Target Skills: {', '.join(target_skills)}

Journal Entries:
{journal_text}

Return ONLY a JSON object with this structure:
{{
  "overall_progress": "excellent|good|moderate|needs_improvement",
  "skills_analysis": {{
    "skill1": {{
      "current_level": "beginner|intermediate|advanced",
      "progress_percentage": 75,
      "strengths": ["strength1", "strength2"],
      "weaknesses": ["weakness1", "weakness2"],
      "time_spent": "X hours",
      "next_milestone": "next milestone",
      "recommendations": ["recommendation1", "recommendation2"]
    }}
  }},
  "study_patterns": {{
    "focus_quality": "high|medium|low",
    "consistency": "excellent|good|poor",
    "optimal_study_times": ["time1", "time2"],
    "distractions": ["distraction1", "distraction2"],
    "productivity_score": 85
  }},
  "burnout_indicators": {{
    "risk_level": "low|medium|high",
    "warning_signs": ["sign1", "sign2"],
    "recommendations": ["recommendation1", "recommendation2"]
  }},
  "actionable_insights": [
    "insight1",
    "insight2",
    "insight3"
  ],
  "next_week_focus": ["focus1", "focus2", "focus3"]
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
        print("Skills Analysis Error:", str(e))
        return {
            "overall_progress": "moderate",
            "skills_analysis": {},
            "study_patterns": {
                "focus_quality": "medium",
                "consistency": "good",
                "productivity_score": 70
            },
            "burnout_indicators": {
                "risk_level": "low",
                "recommendations": ["Take breaks", "Stay consistent"]
            },
            "actionable_insights": ["Keep practicing", "Stay consistent"],
            "next_week_focus": target_skills[:3] if target_skills else ["General improvement"]
        }
