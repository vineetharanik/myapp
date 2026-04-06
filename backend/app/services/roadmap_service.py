from app.services.google_ai_service import generate_skill_roadmap, generate_weekly_plan
from datetime import datetime, timedelta
import json

def generate_skill_roadmap(skill_name: str, current_level: str = "beginner", goals: str = "") -> dict:
    """Generate a comprehensive skill roadmap"""
    client = get_client()

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": "You are an expert educational advisor. Generate comprehensive learning roadmaps. Always return valid JSON."},
            {"role": "user", "content": f"""
Generate a detailed learning roadmap for {skill_name}. Current level: {current_level}. Goals: {goals}.

Return ONLY a JSON object with this structure:
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

Skill: {skill_name}
Current Level: {current_level}
Goals: {goals}
"""}
        ]
    )

    try:
        result_text = response.choices[0].message.content
        return json.loads(result_text)
    except Exception as e:
        print("AI ERROR:", str(e))
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
    """Generate personalized weekly study plan"""
    client = get_client()

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": "You are a study planner and mental health advisor. Create balanced study plans. Always return valid JSON."},
            {"role": "user", "content": f"""
Create a balanced weekly study plan considering:
- Skills: {', '.join(user_skills)}
- Available study hours: {study_hours} hours/day
- Current stress level: {stress_level}%

Return ONLY a JSON object with this structure:
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

Skills: {', '.join(user_skills)}
Study Hours: {study_hours}/day
Stress Level: {stress_level}%
"""}
        ]
    )

    try:
        result_text = response.choices[0].message.content
        return json.loads(result_text)
    except Exception as e:
        print("AI ERROR:", str(e))
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

def analyze_skills_progress(journal_analyses: list, target_skills: list) -> dict:
    """Analyze skills progress based on journal entries"""
    client = get_client()

    # Extract relevant information from journal analyses
    journal_text = "\n".join([
        f"Entry: {analysis.get('summary', '')}\n"
        f"Skills mentioned: {analysis.get('skills_mentioned', [])}\n"
        f"Study time: {analysis.get('study_time_analysis', {})}\n"
        f"Suggestions: {analysis.get('suggestions', [])}"
        for analysis in journal_analyses
    ])

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": "You are an educational progress analyst. Analyze journal entries to track skill development. Always return valid JSON."},
            {"role": "user", "content": f"""
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
  "burnout_indicators": {
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
"""}
        ]
    )

    try:
        result_text = response.choices[0].message.content
        return json.loads(result_text)
    except Exception as e:
        print("AI ERROR:", str(e))
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
