import { pgTable, serial, text, timestamp, integer, uuid} from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

export const reviews = pgTable('reviews', {
  id: serial('id').primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  toiletId: text('toilet_id').notNull().references(() => toilets.id, { onDelete: 'cascade' }),
  rating: integer('rating').notNull(),
  reviewText: text('review_text'),
  createdAt: timestamp('created_at').defaultNow(),
  imageToken: text('image_token'),
  reportCount: integer('report_count').default(0),
});
