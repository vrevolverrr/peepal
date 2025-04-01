import { pgTable, text, timestamp, uuid, pgEnum } from 'drizzle-orm/pg-core'

export const genderEnum = pgEnum('gender', ['male', 'female', 'others'])

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  username: text('username').notNull().unique(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  gender: genderEnum('gender'),
  createdAt: timestamp('created_at').defaultNow()
});
