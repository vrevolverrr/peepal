# app/main.py
from fastapi import FastAPI
from app.routes.users import router as users_router

app = FastAPI()

# Register the users routes
app.include_router(users_router, prefix="/users", tags=["users"])

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI app!"}