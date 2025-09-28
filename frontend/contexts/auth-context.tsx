'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User, loginUser, registerUser, logoutUser, getCurrentUser, verifyToken, createGuestUser } from '@/lib/auth';

interface AuthContextType {
  user: User | null;
  token: string | null;
  loading: boolean;
  remainingSeconds: number | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, passwordConfirmation: string, name?: string) => Promise<void>;
  loginAsGuest: () => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [remainingSeconds, setRemainingSeconds] = useState<number | null>(null);

  // 初回マウント時にトークンをチェック（localStorageとcookieの同期を確保）
  useEffect(() => {
    const storedToken = localStorage.getItem('auth_token');
    const cookieToken = getCookieToken();

    // localStorageとcookieのトークンが一致しない場合は同期
    if (storedToken !== cookieToken) {
      if (storedToken) {
        // localStorageにあるがcookieにない場合はcookieに設定
        setCookieToken(storedToken);
      } else if (cookieToken) {
        // cookieにあるがlocalStorageにない場合はlocalStorageに設定
        localStorage.setItem('auth_token', cookieToken);
      }
    }

    const token = storedToken || cookieToken;
    if (token) {
      verifyAndLoadUser(token);
    } else {
      setLoading(false);
    }
  }, []);

  const verifyAndLoadUser = async (tokenToVerify: string) => {
    try {
      const isValid = await verifyToken(tokenToVerify);
      if (isValid) {
        const userData = await getCurrentUser(tokenToVerify);
        setUser(userData);
        setToken(tokenToVerify);
      } else {
        localStorage.removeItem('auth_token');
      }
    } catch (error) {
      console.error('Failed to verify token:', error);
      localStorage.removeItem('auth_token');
    } finally {
      setLoading(false);
    }
  };

  // Cookieからトークンを取得するヘルパー関数
  const getCookieToken = (): string | null => {
    if (typeof document === 'undefined') return null;
    const cookies = document.cookie.split(';');
    const authCookie = cookies.find(cookie => cookie.trim().startsWith('auth_token='));
    return authCookie ? authCookie.split('=')[1] : null;
  };

  // Cookieにトークンを設定するヘルパー関数
  const setCookieToken = (token: string) => {
    if (typeof document !== 'undefined') {
      document.cookie = `auth_token=${token}; path=/; max-age=${60 * 60 * 24}; SameSite=Lax`;
    }
  };

  const setAuthToken = (token: string) => {
    // localStorageに保存
    localStorage.setItem('auth_token', token);
    // cookieにも保存（middleware用）
    setCookieToken(token);
  };

  const clearAuthToken = () => {
    localStorage.removeItem('auth_token');
    // cookieを削除
    if (typeof document !== 'undefined') {
      document.cookie = 'auth_token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
    }
  };

  const login = async (email: string, password: string) => {
    const response = await loginUser(email, password);
    setUser(response.user);
    setToken(response.token);
    setAuthToken(response.token);
  };

  const register = async (
    email: string,
    password: string,
    passwordConfirmation: string,
    name?: string
  ) => {
    const response = await registerUser(email, password, passwordConfirmation, name);
    setUser(response.user);
    setToken(response.token);
    setAuthToken(response.token);
  };

  const loginAsGuest = async () => {
    const response = await createGuestUser();
    const guestUser: User = {
      id: response.data.user.id,
      email: '',
      name: null,
      is_guest: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    setUser(guestUser);
    setToken(response.data.token);
    setRemainingSeconds(response.data.user.remaining_seconds);
    setAuthToken(response.data.token);
  };

  const logout = async () => {
    await logoutUser();
    setUser(null);
    setToken(null);
    setRemainingSeconds(null);
    clearAuthToken();
  };

  const refreshUser = async () => {
    if (token) {
      try {
        const userData = await getCurrentUser(token);
        setUser(userData);
      } catch (error) {
        console.error('Failed to refresh user:', error);
        await logout();
      }
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        loading,
        remainingSeconds,
        login,
        register,
        loginAsGuest,
        logout,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}