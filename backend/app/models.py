# app/models.py
from app.db import get_db_connection

def create_user(name, email):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute('INSERT INTO users (name, email) VALUES (%s, %s)', (name, email))
    connection.commit()
    cursor.close()
    connection.close()

def get_users():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute('SELECT * FROM users')
    users = cursor.fetchall()
    cursor.close()
    connection.close()
    return users