import { Hono } from "hono"
import { db } from "../../app"
import { users } from "../../db/schema"
import { eq } from "drizzle-orm"
import { validator } from "../../middleware/validator"
import { updateUserSchema } from "../../validators/api/user"

/**
 * The Hono instance for the user API.
 */
const userApi = new Hono()

/**
 * Route-wide error handler.
 *
 * @param {Error} err - The error object.
 * @param {Context} c - The Hono Context object.
 */
userApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in user API ${err}`)
  return c.json({ error: err.message }, 500)
})

/**
 * GET /api/user/ - Health check
 *
 * @param {Context} c - The Hono Context object.
 * 
 * @returns {Promise<{ message: string }>} - The health check message.
 */
userApi.get('/', async (c) => {
  return c.json({ message: 'User API Health Check' }, 200)
})

/**
 * GET /api/user/me - Retrieves the current user's details.
 * 
 * @param {Context} c - The Hono Context object.
 * 
 * @returns {Promise<{ user: User }>} - The current user details or an error message.
 */
userApi.get('/me', async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const [ user ] = await db.select().from(users).where(eq(users.id, userId))
  
  if (!user) {
    logger.info('User requested does not exist', userId)
    return c.json( {error: "User does not exist"}, 404)
  }
  
  return c.json({ user: user }, 200)
})

/**
 * PUT /api/user/update - Updates the current user's details.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {UpdateUserSchema} username - The new username.
 * @param {UpdateUserSchema} email - The new email.
 * @param {UpdateUserSchema} gender - The new gender.
 * 
 * @returns {Promise<{ user: User }>} - The updated user details or an error message.
 */
userApi.put('/update', validator('json', updateUserSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { username, email, gender } = c.req.valid('json')
  const updates: Partial<typeof users.$inferInsert> = {}

  // Check if username is to be updated
  if (username !== undefined) {
    // Check if username is taken
    const [existingUser] = await db.select()
      .from(users)
      .where(eq(users.username, username))
      .limit(1)
    
    if (existingUser && existingUser.id !== userId) {
      logger.info('Username already taken', { username })
      return c.json({ error: 'Username already taken' }, 400)
    }
  
    // Add the username to the updates object
    updates.username = username
  }

  /// Check if email is to be updated
  if (email !== undefined) {
    // Check if email is taken
    const [existingUser] = await db.select()
      .from(users)
      .where(eq(users.email, email))
      .limit(1)
    
    if (existingUser && existingUser.id !== userId) {
      logger.info('Email already taken', { email })
      return c.json({ error: 'Email already taken' }, 400)
    }

    // Add the email to the updates object
    updates.email = email
  }

  // Check if gender is to be updated
  if (gender !== undefined) {
    if (!['male', 'female', 'others'].includes(gender)) {
      logger.info('Invalid gender value', { gender })
      return c.json({ error: 'Invalid gender value' }, 400)
    }
    updates.gender = gender
  }

  // If no valid updates
  if (Object.keys(updates).length === 0) {
    return c.json({ error: 'No valid updates provided' }, 400)
  }

  // Update the user
  const [ updatedUser ] = await db.update(users)
    .set(updates)
    .where(eq(users.id, userId))
    .returning()

  logger.info('User updated successfully', userId, updates)
  return c.json({ user: updatedUser }, 200)
})

/**
 * DELETE /api/user/delete - Deletes the current user.
 *
 * @param {Context} c - The Hono Context object.
 * 
 * @returns {Promise<{ message: string }>} - The deletion message or an error message.
 */
userApi.delete('/delete', async (c) => {
  const logger = c.get('logger')
  const user = c.get('user')

  // Delete the user and get the deleted user data
  const [ deletedUser ] = await db.delete(users)
  .where(eq(users.id, user.id))
  .returning()

  if (!deletedUser) {
    logger.error('User not found for deletion', user.id)
    return c.json({ error: 'User not found' }, 404)
  }

  logger.info('User deleted successfully', user.id)
  return c.json({ message: 'User deleted successfully' }, 200)
})

export default userApi
