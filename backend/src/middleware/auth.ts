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
    c.set('user', decoded)
    await next()
  } catch (error) {
    return c.json({ error: 'Invalid token' }, 401)
  }
}
