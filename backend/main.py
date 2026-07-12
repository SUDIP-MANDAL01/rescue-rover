# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .routers import users, rovers, alerts

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Rescue Rover API")

# Configure CORS
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(rovers.router)
app.include_router(alerts.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to Rescue Rover API"}
