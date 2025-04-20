import { pgTable, index, text, timestamp, uuid, pgEnum } from 'drizzle-orm/pg-core'

export const genderEnum = pgEnum('gender', ['male', 'female', 'others'])

/**
 * Schema for `users` table. This table stores our application data on users.
 */
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  username: text('username').notNull().unique(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  gender: genderEnum('gender'),
  createdAt: timestamp('created_at').defaultNow()
}, (t) => [
  index('idx_users_id').on(t.id),
  /// Username index
  index('idx_users_username').on(t.username),
  /// Email index
  index('idx_users_email').on(t.email)
]);
