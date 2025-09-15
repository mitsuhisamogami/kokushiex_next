const API_BASE_URL = '/api';

export interface User {
  id: number;
  email: string;
  name: string | null;
  is_guest: boolean;
  created_at: string;
  updated_at: string;
}

export interface AuthResponse {
  user: User;
  token: string;
}

export interface GuestUserData {
  id: number;
  is_guest: boolean;
  expires_at: string;
  remaining_seconds: number;
  remaining_time: string;
}

export interface GuestAuthResponse {
  status: string;
  data: {
    user: GuestUserData;
    token: string;
  };
  message: string;
}

export interface AuthError {
  error?: string;
  errors?: string[];
}

// TODO(human): クライアント側でトークンを保存・取得する関数を実装
// localStorage or cookieを使用してトークンを管理
// セキュリティを考慮した実装が必要

export async function registerUser(
  email: string,
  password: string,
  passwordConfirmation: string,
  name?: string
): Promise<AuthResponse> {
  const response = await fetch(`${API_BASE_URL}/auth/register`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email,
      password,
      password_confirmation: passwordConfirmation,
      name,
    }),
  });

  if (!response.ok) {
    const error: AuthError = await response.json();
    throw new Error(error.error || error.errors?.join(', ') || 'Registration failed');
  }

  return response.json();
}

export async function loginUser(email: string, password: string): Promise<AuthResponse> {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    const error: AuthError = await response.json();
    throw new Error(error.error || 'Login failed');
  }

  return response.json();
}

export async function logoutUser(): Promise<void> {
  await fetch(`${API_BASE_URL}/auth/logout`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });
}

export async function getCurrentUser(token: string): Promise<User> {
  const response = await fetch(`${API_BASE_URL}/auth/me`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }

  const data = await response.json();
  return data.user;
}

export async function verifyToken(token: string): Promise<boolean> {
  try {
    const response = await fetch(`${API_BASE_URL}/auth/verify`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      return false;
    }

    const data = await response.json();
    return data.valid === true;
  } catch {
    return false;
  }
}

export async function createGuestUser(): Promise<GuestAuthResponse> {
  const response = await fetch(`${API_BASE_URL}/guest_sessions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    const error: AuthError = await response.json();
    throw new Error(error.error || error.errors?.join(', ') || 'ゲストユーザー作成に失敗しました');
  }

  return response.json();
}