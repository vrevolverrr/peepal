import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { setup, cleanup } from './setup'
import { app } from '../app'
import { AuthResponse, ErrorResponse, ProtectedResponse } from '../types/responses'

describe('Test Authentication', () => {
  beforeAll(async () => {
    await setup()
  })

  afterAll(async () => {
    await cleanup()
  })

  describe('POST /auth/register', () => {
    it('should register a new user', async () => {
      const res = await app.request('/auth/register', {
        method: 'POST',
        body: JSON.stringify({
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123'
      }),
        headers: {
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(200)
      const body = await res.json() as AuthResponse
      expect(body.user).toBeDefined()
      expect(body.token).toBeDefined()
      expect(body.user.username).toBe('testuser')
      expect(body.user.email).toBe('test@example.com')
    })

    it('should not register a user with existing email', async () => {
      const res = await app.request('/auth/register', {
        method: 'POST',
        body: JSON.stringify({
        username: 'testuser2',
        email: 'test@example.com',
        password: 'password123'
      }),
        headers: {
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(400)
      const body = await res.json() as ErrorResponse
      expect(body.error).toBe('User already exists')
    })
  })

  describe('POST /auth/login', () => {
    it('should login existing user', async () => {
      const res = await app.request('/auth/login', {
        method: 'POST',
        body: JSON.stringify({
        email: 'test@example.com',
        password: 'password123'
      }),
        headers: {
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(200)
      const body = await res.json() as AuthResponse
      expect(body.user).toBeDefined()
      expect(body.token).toBeDefined()
      expect(body.user.email).toBe('test@example.com')
    })

    it('should not login with wrong password', async () => {
      const res = await app.request('/auth/login', {
        method: 'POST',
        body: JSON.stringify({
        email: 'test@example.com',
        password: 'wrongpassword'
      }),
        headers: {
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(401)
      const body = await res.json() as ErrorResponse
      expect(body.error).toBe('Invalid credentials')
    })

    it('should not login non-existent user', async () => {
      const res = await app.request('/auth/login', {
        method: 'POST',
        body: JSON.stringify({
        email: 'nonexistent@example.com',
        password: 'password123'
      }),
        headers: {
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(401)
      const body = await res.json() as ErrorResponse
      expect(body.error).toBe('Invalid credentials')
    })
  })

  describe('Protected Routes', () => {
    let token: string

    beforeAll(async () => {
      // Login to get token
      const res = await app.request('/auth/login', {
        method: 'POST',
        body: JSON.stringify({
        email: 'test@example.com',
        password: 'password123'
      }),
        headers: {
          'Content-Type': 'application/json'
        }
      })
      const body = await res.json() as AuthResponse
      token = body.token
    })

    it('should access protected route with valid token', async () => {
      const res = await app.request('/api/protected', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      expect(res.status).toBe(200)
      const body = await res.json() as ProtectedResponse
      expect(body.message).toBe('Protected route')
      expect(body.user).toBeDefined()
    })

    it('should not access protected route without token', async () => {
      const res = await app.request('/api/protected')

      expect(res.status).toBe(401)
      const body = await res.json() as ErrorResponse
      expect(body.error).toBe('No token provided')
    })

    it('should not access protected route with invalid token', async () => {
      const res = await app.request('/api/protected', {
        headers: {
          'Authorization': 'Bearer invalid-token'
        }
      })

      expect(res.status).toBe(401)
      const body = await res.json() as ErrorResponse
      expect(body.error).toBe('Invalid token')
    })
  })
})
