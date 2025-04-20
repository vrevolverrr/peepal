import { ZodSchema } from 'zod'
import type { ValidationTargets } from 'hono'
import { zValidator} from '@hono/zod-validator'

/**
 * Validator middleware that validates the request data. This validator is a 
 * custom implementation of the `zValidator` from `@hono/zod-validator`.
 *
 * @param {Target} target - The target to validate.
 * @param {ZodSchema} schema - The schema to validate against.
 */
export const validator = <T extends ZodSchema, Target extends keyof ValidationTargets>(
  target: Target,
  schema: T
) =>
  zValidator(target, schema, (result, c) => {
    if (!result.success) {
      c.get('logger').error(result.error.message)
      return c.json({ error: `Bad request: ${Object.keys(result.error.flatten().fieldErrors).join(', ')}` }, 400)
    }
  })