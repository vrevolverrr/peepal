import { pgTable, serial, timestamp, integer } from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

export const history = pgTable('history', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id, { onDelete: 'cascade' }),
  toiletId: integer('toilet_id').references(() => toilets.id, { onDelete: 'cascade' }),
  visitedAt: timestamp('visited_at').defaultNow()
});
