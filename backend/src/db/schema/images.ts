import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core'
import { users } from './users'

export const images = pgTable('images', {
  token: text('token').notNull().primaryKey(),
  type: text('type').notNull(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'set null' }),
  filename: text('filename').notNull(),
  uploadedAt: timestamp('uploaded_at').defaultNow(),
});
