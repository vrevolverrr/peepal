import { Context, Next } from 'hono'
import jwt from 'jsonwebtoken'
import { JWTPayload } from '../types/auth'

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'

  /**
   * Authentication middleware that checks if a valid JWT token is present in the Authorization header.
   *
   * If the token is present and valid, it decodes the token and sets the `user` property on the context object.
   * If the token is invalid or not present, it returns a 401 response.
   *
   * @param {Context} c - The Hono Context object.
   * @param {Next} next - The next middleware function to call.
   */
export async function authMiddleware(c: Context, next: Next) {
  // Auth header format: Bearer <token>
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
