import { pgTable, serial, text, timestamp, integer, uuid } from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

export const reviews = pgTable('reviews', {
  id: serial('id').primaryKey(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }),
  toiletId: integer('toilet_id').references(() => toilets.id, { onDelete: 'cascade' }),
  rating: integer('rating').notNull(),
  reviewText: text('review_text'),
  createdAt: timestamp('created_at').defaultNow(),
  imageUrl: text('image_url'),
  reportCount: integer('report_count').default(0)
});
