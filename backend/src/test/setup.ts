import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { migrate } from 'drizzle-orm/node-postgres/migrator'
import config from '../../drizzle.config'
import { users, toilets, reviews, favorites, history, notifications } from '../db/schema'
import { pool } from '../db/db'

export const db = drizzle(pool)

// Clean up function to run after tests
export async function cleanup() {
  // Close test database connection
  await pool.end()
}

// Setup function to run before tests
export async function setup() {    
  // Run migrations
  await migrate(db, { migrationsFolder: './drizzle' })

  // Clear all tables in reverse order of dependencies
  await db.delete(notifications)
  await db.delete(history)
  await db.delete(favorites)
  await db.delete(reviews)
  await db.delete(toilets)
  await db.delete(users)
}
