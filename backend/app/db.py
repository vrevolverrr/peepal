# app/db.py
from fastapi import FastAPI
import mysql.connector

def get_db_connection():
    connection = mysql.connector.connect(
        host='127.0.0.1',
        user='root',
        password='3239778',
        database='peepal',
        unix_socket="/tmp/mysql.sock"
    )
    return connection

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