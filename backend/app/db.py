from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from fastapi import FastAPI

# Define your database URL (for MySQL in this case)
SQLALCHEMY_DATABASE_URL = "mysql+mysqlconnector://root:3239778@127.0.0.1/peepal"

# Create engine for the database connection
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# Create a base class for your models
Base = declarative_base()

# Create sessionmaker to handle database sessions
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

'''
To check if connected to database.
command: uvicorn db:app --reload
app = FastAPI()

@app.get("/")
def read_root():
    db_connection = get_db_connection()
    cursor = db_connection.cursor()
    cursor.execute("SELECT DATABASE();")
    current_db = cursor.fetchone()
    cursor.close()
    db_connection.close()
    return {"Connected to database": current_db[0]}'
'''