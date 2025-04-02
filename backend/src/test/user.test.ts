import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { app, db } from '../app'
import { users } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

interface UserResponse {
  user: {
    id: string
    username: string
    email: string
    gender?: 'male' | 'female' | 'others'
    createdAt: string
  }
}

interface ErrorResponse {
  error: string
}

interface SuccessResponse {
  message: string
}

describe('Test User API', () => {
  let testUser: any
  let authToken: string

  // Set up test database and create test user
  beforeAll(async () => {    
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    const [ user ] = await db.insert(users).values({
      username: 'testuser2',
      email: 'test2@example.com',
      passwordHash,
      gender: 'male'
    }).returning()

    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')
  })

  // Delete the test user after all tests
  afterAll(async () => {
    await db.delete(users).where(eq(users.email, 'test2@example.com'))
  })

  describe('GET /api/users/me', () => {
    it('should return user data for authenticated user', async () => {
      const res = await app.request('/api/users/me', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user).toBeDefined()
      expect(data.user.username).toBe('testuser2')
      expect(data.user.email).toBe('test2@example.com')
      expect(data.user.gender).toBe('male')
    })

    it('should return 401 without auth token', async () => {
      const res = await app.request('/api/users/me')
      expect(res.status).toBe(401)
    })
  })

  describe('PUT /api/users/update', () => {
    it('should update username successfully', async () => {
      const res = await app.request('/api/users/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          username: 'newusername'
        })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user.username).toBe('newusername')
    })

    it('should update email successfully', async () => {
      const res = await app.request('/api/users/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: 'newemail@example.com'
        })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user.email).toBe('newemail@example.com')
    })

    it('should update gender successfully', async () => {
      const res = await app.request('/api/users/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          gender: 'female'
        })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user.gender).toBe('female')
    })

    it('should reject invalid gender value', async () => {
      const res = await app.request('/api/users/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          gender: 'invalid'
        })
      })

      expect(res.status).toBe(400)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Invalid gender value')
    })

    it('should reject update without changes', async () => {
      const res = await app.request('/api/users/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })

      expect(res.status).toBe(400)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('No valid updates provided')
    })
  })

  describe('DELETE /api/users/delete', () => {
    it('should delete user successfully', async () => {
      const res = await app.request('/api/users/delete', {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as SuccessResponse
      expect(data.message).toBe('User deleted successfully')

      // Verify user is deleted
      const [ user ] = await db.select()
        .from(users)
        .where(eq(users.id, testUser.id))
        .limit(1)
      
      expect(user).toBeUndefined()
    })

    it('should return 401 without auth token', async () => {
      const res = await app.request('/api/users/delete', {
        method: 'DELETE'
      })
      expect(res.status).toBe(401)
    })
  })
})
