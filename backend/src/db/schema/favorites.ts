import { pgTable, serial, timestamp, uuid, index, text, unique } from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

/**
 * Schema for `favorites` table. This table stores our application data on favorites of toilets by users.
 */
export const favorites = pgTable('favorites', {
  // The ID of the favorite entry.
  id: serial('id').primaryKey(),

  // The ID of the user who favorited this toilet.
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),

  // The ID of the toilet favorited.
  toiletId: text('toilet_id').notNull().references(() => toilets.id, { onDelete: 'cascade' }),

  // The timestamp when the toilet was favorited.
  createdAt: timestamp('created_at').defaultNow().notNull()
}, (t) => [
  unique().on(t.userId, t.toiletId),
  index('idx_favorites_id').on(t.id),
  index('idx_favorites_user_id').on(t.userId),
  index('idx_favorites_toilet_id').on(t.toiletId)
]);