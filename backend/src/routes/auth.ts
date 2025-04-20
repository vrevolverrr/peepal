import { Hono } from 'hono'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { eq } from 'drizzle-orm'
import { db } from '../app'
import { users } from '../db/schema'
import { JWTPayload } from '../types/auth'
import { registerSchema, loginSchema } from '../validators/auth'
import { validator } from '../middleware/validator'

const auth = new Hono()
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'

/**
 * Route-wide error handler.
 *
 * @param {Error} error - The error object.
 * @param {Context} c - The Hono Context object.
 */
auth.onError((error, c) => {
  const logger = c.get('logger')
  logger.error('Error in auth API', error)
  
  return c.json({ error: 'Internal server error' }, 500)
})

/**
 * Retrieves the health check message for the auth API.
 *
 * @param {Context} c - The Hono Context object.
 * 
 * @returns {Promise<{ message: string }>} - The health check message.
 */
auth.get('/', async (c) => {
  return c.json({ message: 'Auth API Health Check'}, 200)
})

/**
 * Registers a new user.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {RegisterSchema} username - The username of the new user.
 * @param {RegisterSchema} email - The email of the new user.
 * @param {RegisterSchema} password - The password of the new user.
 * @param {RegisterSchema} gender - The gender of the new user.
 * 
 * @returns {Promise<{ user: User, token: string }> - The registered user and their token.
 */
auth.post('/signup', validator('json', registerSchema), async (c) => {
  const log = c.get('logger')

  const { username, email, password, gender } = c.req.valid('json')

  // Check if user already exists
  const [ existingUser ] = await db.select().from(users).where(eq(users.email, email)).limit(1)
  
  if (existingUser != undefined) {
    // Bad request, user already exists
    log.info(`User ${existingUser.id} exists`)
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
})

/**
 * Logs in an existing user.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {LoginSchema} email - The email of the user.
 * @param {LoginSchema} password - The password of the user.
 * 
 * @returns {Promise<{ user: User, token: string }>} - The logged in user and their token.
 */
auth.post('/login', validator('json', loginSchema), async (c) => {
  const { email, password } = c.req.valid('json')

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
      email: user.email,
      gender: user.gender
    },
    token
  })
})

export default auth
