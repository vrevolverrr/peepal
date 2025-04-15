import { pgTable, serial, timestamp, integer, uuid, index, text, unique } from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

export const favorites = pgTable('favorites', {
  id: serial('id').primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  toiletId: text('toilet_id').notNull().references(() => toilets.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull()
}, (t) => [
  unique().on(t.userId, t.toiletId),
  index('idx_favorites_id').on(t.id),
  index('idx_favorites_user_id').on(t.userId),
  index('idx_favorites_toilet_id').on(t.toiletId)
]);