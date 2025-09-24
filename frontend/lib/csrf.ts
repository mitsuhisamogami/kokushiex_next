/**
 * CSRF Token Management Utilities
 * Double Submit Cookie パターンの実装
 */

/**
 * CookieからCSRFトークンを読み取る
 * @param name Cookie名（デフォルト: '_csrf_token'）
 * @returns CSRFトークン文字列またはnull
 */
export function getCsrfTokenFromCookie(name: string = '_csrf_token'): string | null {
  if (typeof document === 'undefined') {
    // サーバーサイドレンダリング時はnull
    return null;
  }

  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);

  if (parts.length === 2) {
    const token = parts.pop()?.split(';').shift();
    return token || null;
  }

  return null;
}

/**
 * レスポンスからCSRFトークンを抽出する
 * @param response fetch Response オブジェクト
 * @returns CSRFトークン文字列またはnull
 */
export function extractCsrfTokenFromResponse(response: Response): string | null {
  // ヘッダーから取得を試行
  const headerToken = response.headers.get('X-CSRF-Token');
  if (headerToken) {
    return headerToken;
  }

  return null;
}

/**
 * APIリクエスト用のヘッダーにCSRFトークンを追加
 * @param headers 既存のヘッダーオブジェクト
 * @returns CSRFトークンが追加されたヘッダーオブジェクト
 */
export function addCsrfTokenToHeaders(headers: HeadersInit = {}): HeadersInit {
  const csrfToken = getCsrfTokenFromCookie();

  if (!csrfToken) {
    return headers;
  }

  // HeadersInitの形式に応じて処理
  if (headers instanceof Headers) {
    headers.set('X-CSRF-Token', csrfToken);
    return headers;
  }

  if (Array.isArray(headers)) {
    return [...headers, ['X-CSRF-Token', csrfToken]];
  }

  // Record<string, string> 形式
  return {
    ...headers,
    'X-CSRF-Token': csrfToken
  };
}

/**
 * CSRFエラーかどうかを判定
 * @param response fetch Response オブジェクト
 * @returns CSRFエラーの場合true
 */
export function isCsrfError(response: Response): boolean {
  return response.status === 403;
}

/**
 * CSRF保護が必要なHTTPメソッドかどうかを判定
 * @param method HTTPメソッド
 * @returns 保護が必要な場合true
 */
export function requiresCsrfProtection(method: string): boolean {
  const protectedMethods = ['POST', 'PUT', 'PATCH', 'DELETE'];
  return protectedMethods.includes(method.toUpperCase());
}