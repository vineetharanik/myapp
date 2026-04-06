from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import auth, stress, journal, planner
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend API for AI Productivity App",
    version="1.0.0"
)

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Expand to specifically allowed origins in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(stress.router, prefix="/stress", tags=["stress"])
app.include_router(journal.router, prefix="/journal", tags=["journal"])
app.include_router(planner.router, prefix="/planner", tags=["planner"])

@app.get("/")
def read_root():
    return {"message": "Welcome to DevBalance AI Backend. Read to go!"}
