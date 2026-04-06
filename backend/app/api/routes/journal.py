from fastapi import APIRouter, Depends, HTTPException
from app.services.google_ai_service import analyze_journal
from app.models.schemas import JournalEntry, JournalAnalysis
from app.models.journal_history import JournalAnalysisWithTimestamp
from app.api.dependencies import get_current_user
from typing import List
from datetime import datetime

router = APIRouter()

# In-memory storage for demo purposes
# In production, use a proper database
journal_history: List[JournalAnalysisWithTimestamp] = []

@router.post("/analyze", response_model=JournalAnalysis)
def analyze_journal_endpoint(entry: JournalEntry):
    """Analyze journal entry using Google Gemini AI"""
    try:
        result_dict = analyze_journal(entry.text)
        
        # Convert dict to JournalAnalysis model
        analysis = JournalAnalysis(**result_dict)
        
        # Store in history (in production, use database)
        journal_history.append(
            JournalAnalysisWithTimestamp(
                timestamp=datetime.now(),
                analysis=analysis,
                original_text=entry.text
            )
        )
        
        # Keep only last 50 entries
        if len(journal_history) > 50:
            journal_history.pop(0)
        
        return analysis
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@router.get("/history", response_model=List[JournalAnalysisWithTimestamp])
def get_journal_history():
    """Get all journal analyses"""
    return journal_history

@router.get("/latest", response_model=JournalAnalysisWithTimestamp)
def get_latest_analysis():
    """Get the latest journal analysis"""
    if not journal_history:
        raise HTTPException(status_code=404, detail="No journal entries found")
    
    # Sort by timestamp descending and return the latest
    sorted_history = sorted(journal_history, key=lambda x: x.timestamp, reverse=True)
    return sorted_history[0]
