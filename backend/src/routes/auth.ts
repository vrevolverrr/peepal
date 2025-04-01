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
  gender?: 'male' | 'female' | 'others'
}

interface LoginBody {
  email: string
  password: string
}

auth.post('/signup', async (c) => {
  const log = c.get('logger')

  try {
    const body = await c.req.json<RegisterBody>()
    const { username, email, password, gender } = body

    // Check if user already exists
    const [ existingUser ] = await db.select().from(users).where(eq(users.email, email)).limit(1)
    
    if (existingUser != undefined) {
      // Bad request, user already exists
      log.info(`User ${existingUser.id} exists, returning 400`)
      return c.json({ error: 'User already exists' }, 400)
    }

    log.info('Creating user with', { username, email })

    /// Hash the user's password
    const salt = await bcrypt.genSalt(10)
    const passwordHash = await bcrypt.hash(password, salt)

    // Create user in DB
    const [ newUser ] = await db.insert(users).values({
      username,
      email,
      passwordHash,
      gender
    }).returning({ id: users.id, username: users.username, email: users.email, gender: users.gender })
    
    log.info('Succesfully created user', newUser.id)

    // Generate JWT token
    const payload: JWTPayload = { id: newUser.id, username: newUser.username }
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' })

    return c.json({ user: newUser, token }, 200)
  } catch (error) {
    console.log(error)
    log.error('Error registering user', error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

auth.post('/login', async (c) => {
  try {
    const { email, password } = await c.req.json<LoginBody>()

    // Fetch user from DB
    const [ user ] = await db.select().from(users).where(eq(users.email, email)).limit(1)
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

export default auth
