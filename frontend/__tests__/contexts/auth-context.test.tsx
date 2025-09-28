/**
 * AuthContextのテスト
 * 認証システムの核心的な機能をテストします
 */

import React from 'react'
import { render, screen, waitFor, act } from '@testing-library/react'
import '@testing-library/jest-dom'
import { AuthProvider, useAuth } from '@/contexts/auth-context'

// テスト用のコンポーネント
function TestComponent() {
  const { user, loading, token, login } = useAuth()

  if (loading) {
    return <div data-testid="loading">Loading...</div>
  }

  return (
    <div>
      <div data-testid="user-status">
        {user ? `Authenticated: ${user.email}` : 'Not authenticated'}
      </div>
      <div data-testid="token-status">
        {token ? 'Has token' : 'No token'}
      </div>
      <button
        data-testid="login-button"
        onClick={() => login('test@example.com', 'password')}
      >
        Login
      </button>
    </div>
  )
}

// fetchのモック設定
const mockFetch = jest.fn()
global.fetch = mockFetch

// localStorageのモック
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}

describe('AuthContext', () => {
  beforeEach(() => {
    jest.clearAllMocks()

    // localStorageのモックをリセット
    localStorageMock.getItem.mockReturnValue(null)
    localStorageMock.setItem.mockClear()
    localStorageMock.removeItem.mockClear()

    // グローバルlocalStorageを置き換え
    Object.defineProperty(window, 'localStorage', {
      value: localStorageMock,
      writable: true
    })

    // documentオブジェクトとcookieのモック
    Object.defineProperty(document, 'cookie', {
      writable: true,
      value: '',
    })
  })

  describe('初期状態', () => {
    it('トークンがない場合は未認証状態になる', async () => {
      localStorageMock.getItem.mockReturnValue(null)

      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>
      )

      // ローディング完了後、未認証状態になる
      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Not authenticated')
        expect(screen.getByTestId('token-status')).toHaveTextContent('No token')
      })
    })

    it('有効なトークンがある場合は認証状態になる', async () => {
      const testToken = 'valid-token-123'
      const testUser = {
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        is_guest: false,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
      }

      localStorageMock.getItem.mockReturnValue(testToken)

      // トークン検証APIをモック
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ valid: true }),
      })

      // ユーザー情報取得APIをモック
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ user: testUser }),
      })

      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>
      )

      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Authenticated: test@example.com')
        expect(screen.getByTestId('token-status')).toHaveTextContent('Has token')
      })
    })
  })

  describe('トークン同期', () => {
    it('localStorageのトークンがcookieに同期される', async () => {
      const testToken = 'sync-token-456'
      const testUser = {
        id: 1,
        email: 'sync@example.com',
        name: 'Sync User',
        is_guest: false,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
      }

      localStorageMock.getItem.mockReturnValue(testToken)

      // APIレスポンスをモック
      mockFetch
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ valid: true }),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ user: testUser }),
        })

      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>
      )

      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Authenticated: sync@example.com')
      })

      // cookieに同期されることを確認
      expect(document.cookie).toContain(`auth_token=${testToken}`)
    })
  })

  describe('ログイン機能', () => {
    it('ログイン成功時にユーザー情報とトークンが設定される', async () => {
      const loginResponse = {
        user: {
          id: 2,
          email: 'login@example.com',
          name: 'Login User',
          is_guest: false,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        },
        token: 'login-token-789',
      }

      localStorageMock.getItem.mockReturnValue(null)

      // ログインAPIをモック
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => loginResponse,
      })

      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>
      )

      // 初期状態を確認
      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Not authenticated')
      })

      // ログインボタンをクリック
      await act(async () => {
        screen.getByTestId('login-button').click()
      })

      // ログイン後の状態を確認
      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Authenticated: login@example.com')
        expect(screen.getByTestId('token-status')).toHaveTextContent('Has token')
      })

      // localStorageとcookieに保存されることを確認
      expect(localStorageMock.setItem).toHaveBeenCalledWith('auth_token', 'login-token-789')
      expect(document.cookie).toContain('auth_token=login-token-789')
    })
  })

  describe('エラーハンドリング', () => {
    it('無効なトークンの場合は認証をクリアする', async () => {
      const invalidToken = 'invalid-token'
      localStorage.getItem = jest.fn().mockReturnValue(invalidToken)

      // トークン検証が失敗をモック
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
      })

      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>
      )

      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Not authenticated')
        expect(screen.getByTestId('token-status')).toHaveTextContent('No token')
      })

      // トークンが削除されることを確認
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_token')
    })

    it('ネットワークエラーの場合は認証をクリアする', async () => {
      const errorToken = 'network-error-token'
      localStorage.getItem = jest.fn().mockReturnValue(errorToken)

      // ネットワークエラーをモック
      mockFetch.mockRejectedValueOnce(new Error('Network error'))

      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>
      )

      await waitFor(() => {
        expect(screen.getByTestId('user-status')).toHaveTextContent('Not authenticated')
        expect(screen.getByTestId('token-status')).toHaveTextContent('No token')
      })

      // トークンが削除されることを確認
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_token')
    })
  })
})