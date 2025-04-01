import { Context, Next } from 'hono'
import jwt from 'jsonwebtoken'
import { JWTPayload } from '../types/auth'

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'

export async function authMiddleware(c: Context, next: Next) {
  const token = c.req.header('Authorization')?.split(' ')[1]
  
  if (!token) {
    return c.json({ error: 'No token provided' }, 401)
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as JWTPayload
    /// Forward the request to the next handler with the decoded user
    c.set('user', decoded)
    await next()
  } catch (error) {
    /// User is not authenticated, return 401
    return c.json({ error: 'Invalid token' }, 401)
  }
}
