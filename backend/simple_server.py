from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.services.google_ai_service import analyze_journal
import uvicorn

app = FastAPI(title="DevBalance AI Backend")

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "DevBalance AI Backend is running!", "status": "API Key configured"}

@app.post("/journal/analyze")
def analyze_journal_endpoint(text: str):
    try:
        result = analyze_journal(text)
        return {"success": True, "data": result}
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
