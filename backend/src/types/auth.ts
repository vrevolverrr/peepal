export interface JWTPayload {
  id: string;
  username: string;
}

/// This type extends the ContextVariableMap interface from Hono to add
/// a `user` property of type `JWTPayload` to the context object
declare module 'hono' {
  interface ContextVariableMap {
    user: JWTPayload;
  }
}
