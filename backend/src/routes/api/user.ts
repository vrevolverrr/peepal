import { Hono } from "hono"
import { db } from "../../app"
import { users } from "../../db/schema"
import { eq } from "drizzle-orm"

const userApi = new Hono()

interface UpdateUserBody {
  username?: string
  email?: string
  gender?: 'male' | 'female' | 'others'
}

userApi.get('/me', async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  try {
    const [ user ] = await db.select().from(users).where(eq(users.id, userId))
  
    if (user == undefined) {
      logger.info('User requested does not exist', userId)
      return c.json( {error: "User does not exist"}, 400)
    }
    
    return c.json({ user: user }, 200)
  } catch (error) {
    logger.error(`Error fetching user for ${userId}`, error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

userApi.put('/update', async (c) => {
  const logger = c.get('logger')
  const user = c.get('user')

  try {
    const body = await c.req.json<UpdateUserBody>()
    const updates: Partial<typeof users.$inferInsert> = {}

    // Check if username is to be updated
    if (body.username !== undefined) {
      // Check if username is taken
      const [existingUser] = await db.select()
        .from(users)
        .where(eq(users.username, body.username))
        .limit(1)
      
      if (existingUser && existingUser.id !== user.id) {
        logger.info('Username already taken', { username: body.username })
        return c.json({ error: 'Username already taken' }, 400)
      }
    
      // Add the username to the updates object
      updates.username = body.username
    }

    /// Check if email is to be updated
    if (body.email !== undefined) {
      // Check if email is taken
      const [existingUser] = await db.select()
        .from(users)
        .where(eq(users.email, body.email))
        .limit(1)
      
      if (existingUser && existingUser.id !== user.id) {
        logger.info('Email already taken', { email: body.email })
        return c.json({ error: 'Email already taken' }, 400)
      }

      // Add the email to the updates object
      updates.email = body.email
    }

    // Check if username is to be updated
    if (body.gender !== undefined) {
      if (!['male', 'female', 'others'].includes(body.gender)) {
        logger.info('Invalid gender value', { gender: body.gender })
        return c.json({ error: 'Invalid gender value' }, 400)
      }
      updates.gender = body.gender
    }

    // If no valid updates
    if (Object.keys(updates).length === 0) {
      return c.json({ error: 'No valid updates provided' }, 400)
    }

    // Update the user
    const [ updatedUser ] = await db.update(users)
      .set(updates)
      .where(eq(users.id, user.id))
      .returning()

    logger.info('User updated successfully', user.id, updates)
    return c.json({ user: updatedUser }, 200)

  } catch (error) {
    logger.error('Error updating user', user.id, error )
    return c.json({ error: 'Internal server error' }, 500)
  }
})

userApi.delete('/delete', async (c) => {
  const logger = c.get('logger')
  const user = c.get('user')

  try {
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

  } catch (error) {
    logger.error('Error deleting user', user.id, error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

export default userApi
