import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core'
import { users } from './users'

/**
 * Schema for `images` table. This table stores our application data on images.
 */
export const images = pgTable('images', {
  // The token that is used to identify this image resource entry.
  token: text('token').notNull().primaryKey(),

  // The type of image, either `toilet` or `review`.
  type: text('type').notNull(),

  // The ID of the user who uploaded this image.
  userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }),

  // The filename of the image.
  filename: text('filename').notNull(),

  // The timestamp when the image was uploaded.
  uploadedAt: timestamp('uploaded_at').defaultNow(),
});
