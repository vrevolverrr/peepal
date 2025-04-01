import { Context, Next } from "hono"
import pino from "pino"

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

  logger.info({ method: c.req.method, url: c.req.url })

  c.set('logger', logger)
  
  // Forward the request to the next handler
  await next()
}