import { pgTable, serial, timestamp, uuid, text } from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

/**
 * Schema for `history` table. This table stores our application data on history of toilets visited by users.
 */
export const history = pgTable('history', {
  // The ID of the history entry.
  id: serial('id').primaryKey(),

  // The ID of the user who visited this toilet.
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }),

  // The ID of the toilet visited.
  toiletId: text('toilet_id').references(() => toilets.id, { onDelete: 'cascade' }),

  // The timestamp when the toilet was visited.
  visitedAt: timestamp('visited_at').defaultNow()
});
