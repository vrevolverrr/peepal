# app/main.py
from fastapi import FastAPI, HTTPException
from sqlalchemy.orm import Session
from app.db import engine, Base, get_db
from sqlalchemy import text

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI app!"}

@app.on_event("startup")
def test_db_connection():
    try:
        # Create a session to test the database connection
        db = next(get_db())  # Get the DB session using the dependency
        db.execute(text("SELECT 1"))  # Run a simple query to check if the DB is connected
        db.close()  # Don't forget to close the session
        print("Database connected successfully!")
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")