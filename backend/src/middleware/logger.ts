import { Context, Next } from "hono"
import pino from "pino"

/**
 * Logger middleware that logs the request and response.
 *
 * @param {Context} c - The Hono Context object.
 * @param {Next} next - The next middleware function to call.
 */
export async function logger(c: Context, next: Next) {
  const logger = pino({
    name: c.req.url.split('/').slice(-2).join('/'),
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'HH:MM:ss Z',
        ignore: 'pid,hostname',
      },
    },
  })

  c.set('logger', logger)
  
  // Forward the request to the next handler
  await next()

  logger.info({ method: c.req.method, url: c.req.url, status: c.res.status })
}