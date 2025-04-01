import { Context, Next } from "hono"
import pino from "pino"

export async function logger(c: Context, next: Next) {
  const logger = pino({name: c.req.routePath})

  logger.info('Request received', { method: c.req.method, url: c.req.url })

  c.set('logger', logger)
  
  // Forward the request to the next handler
  await next()
}