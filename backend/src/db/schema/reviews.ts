import { pgTable, serial, text, timestamp, integer, uuid} from 'drizzle-orm/pg-core'
import { users } from './users'
import { toilets } from './toilets'

/**
 * Schema for `reviews` table. This table stores our application data on reviews for each toilet.
 */
export const reviews = pgTable('reviews', {
  // The ID of the review.
  id: serial('id').primaryKey(),

  // The ID of the user who wrote this review.
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),

  // The ID of the toilet this review is for.
  toiletId: text('toilet_id').notNull().references(() => toilets.id, { onDelete: 'cascade' }),

  // The rating given by the user.
  rating: integer('rating').notNull(),

  // The review text.
  reviewText: text('review_text'),
  createdAt: timestamp('created_at').defaultNow(),
  imageToken: text('image_token'),
  reportCount: integer('report_count').default(0),
});
