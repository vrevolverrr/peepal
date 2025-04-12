import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest'
import { app, db } from '../app'
import { users } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

// Mock Minio client
vi.mock('minio', () => {
  return {
    Client: vi.fn().mockImplementation(() => ({
    }))
  }
})

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
    // Generate unique test data with timestamps
    const timestamp = Date.now();
    const testUsername = `testuser_${timestamp}`;
    const testEmail = `test_${timestamp}@example.com`;
    
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    
    // First check if the user already exists
    let user;
    const existingUsers = await db.select().from(users).where(eq(users.email, testEmail));
    
    if (existingUsers.length === 0) {
      const [newUser] = await db.insert(users).values({
        username: testUsername,
        email: testEmail,
        passwordHash,
        gender: 'male'
      }).returning();
      user = newUser;
    } else {
      user = existingUsers[0];
    }

    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')
  })

  // Delete the test user after all tests
  afterAll(async () => {
    if (testUser && testUser.email) {
      await db.delete(users).where(eq(users.email, testUser.email))
    }
  })

  describe('GET /api/user/me', () => {
    it('should return user data for authenticated user', async () => {
      const res = await app.request('/api/user/me', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user).toBeDefined()
      expect(data.user.username).toBe(testUser.username)
      expect(data.user.email).toBe(testUser.email)
      expect(data.user.gender).toBe('male')
    })

    it('should return 401 without auth token', async () => {
      const res = await app.request('/api/user/me')
      expect(res.status).toBe(401)
    })
  })

  describe('PUT /api/user/update', () => {
    it('should update username successfully', async () => {
      // Generate a unique username with timestamp
      const uniqueUsername = `newuser_${Date.now()}`;
      
      const res = await app.request('/api/user/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          username: uniqueUsername
        })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user.username).toBe(uniqueUsername)
    })

    it('should update email successfully', async () => {
      // Generate a unique email with timestamp
      const uniqueEmail = `newemail_${Date.now()}@example.com`;
      
      const res = await app.request('/api/user/update', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: uniqueEmail
        })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as UserResponse
      expect(data.user.email).toBe(uniqueEmail)
    })

    it('should update gender successfully', async () => {
      const res = await app.request('/api/user/update', {
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
      const res = await app.request('/api/user/update', {
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
    })

    it('should reject update without changes', async () => {
      const res = await app.request('/api/user/update', {
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

  describe('DELETE /api/user/delete', () => {
    it('should delete user successfully', async () => {
      const res = await app.request('/api/user/delete', {
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
      const res = await app.request('/api/user/delete', {
        method: 'DELETE'
      })
      expect(res.status).toBe(401)
    })
  })
})
