import pino from "pino";

declare module 'hono' {
    interface ContextVariableMap {
        logger: pino.Logger
    }
}