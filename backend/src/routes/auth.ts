import { Hono } from 'hono'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { eq } from 'drizzle-orm'
import { db } from '../app'
import { users } from '../db/schema'
import { JWTPayload } from '../types/auth'

const auth = new Hono()
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'

interface RegisterBody {
  username: string
  email: string
  password: string
}

interface LoginBody {
  email: string
  password: string
}

// Register new user
auth.post('/register', async (c) => {
  try {
    const body = await c.req.json<RegisterBody>()
    console.log('Registration request:', body)
    const { username, email, password } = body

    // Check if user already exists
    const existingUser = await db.select().from(users).where(eq(users.email, email)).limit(1)
    console.log('Existing user check:', existingUser)
    
    if (existingUser.length > 0) {
      console.log('User exists, returning 400')
      return c.json({ error: 'User already exists' }, 400)
    }

    /// Hash the user's password
    const salt = await bcrypt.genSalt(10)
    const passwordHash = await bcrypt.hash(password, salt)

    // Create user in DB
    console.log('Creating user with:', { username, email })
    const [newUser] = await db.insert(users).values({
      username,
      email,
      passwordHash
    }).returning({ id: users.id, username: users.username, email: users.email })
    console.log('Created user:', newUser)

    // Generate JWT token
    const payload: JWTPayload = { id: newUser.id, username: newUser.username }
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' })

    return c.json({ user: newUser, token }, 200)
  } catch (error) {
    console.error('Registration error:', error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

// Login user
auth.post('/login', async (c) => {
  try {
    const { email, password } = await c.req.json<LoginBody>()

    // Find user
    const [user] = await db.select().from(users).where(eq(users.email, email)).limit(1)
    if (!user) {
      return c.json({ error: 'Invalid credentials' }, 401)
    }

    // Check password
    const validPassword = await bcrypt.compare(password, user.passwordHash)
    if (!validPassword) {
      return c.json({ error: 'Invalid credentials' }, 401)
    }

    // Generate JWT token
    const payload: JWTPayload = { id: user.id, username: user.username }
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' })

    return c.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      },
      token
    })
  } catch (error) {
    console.error('Login error:', error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

// Get current user
auth.get('/me', async (c) => {
  try {
    const user = c.get('user')
    if (!user) {
      return c.json({ error: 'Not authenticated' }, 401)
    }

    const [userData] = await db.select({
      id: users.id,
      username: users.username,
      email: users.email
    })
    .from(users)
    .where(eq(users.id, user.id))
    .limit(1)

    if (!userData) {
      return c.json({ error: 'User not found' }, 404)
    }

    return c.json({ user: userData })
  } catch (error) {
    console.error('Get user error:', error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

export default auth
