interface UserResponse {
  id: number;
  username: string;
  email: string;
}

export interface AuthResponse {
  user: UserResponse;
  token: string;
}

export interface ErrorResponse {
  error: string;
}

export interface ProtectedResponse {
  message: string;
  user: {
    id: number;
    username: string;
  };
}
