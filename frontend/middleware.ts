import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// 認証が不要なパス
const publicPaths = ['/signin', '/signup', '/api/health', '/'];

// 認証が必要なパス
const protectedPaths = ['/dashboard', '/profile', '/settings'];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // publicパスはそのまま通す
  if (publicPaths.some(path => pathname === path || pathname.startsWith('/api/'))) {
    return NextResponse.next();
  }

  // 保護されたパスの場合はトークンをチェック
  if (protectedPaths.some(path => pathname.startsWith(path))) {
    // クッキーからトークンを取得（クライアントサイドのlocalStorageは使えない）
    const token = request.cookies.get('auth_token')?.value;

    if (!token) {
      // トークンがない場合はサインインページにリダイレクト
      return NextResponse.redirect(new URL('/signin', request.url));
    }

    // トークンの検証
    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://backend:3000/api'}/auth/verify`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        // トークンが無効な場合はサインインページにリダイレクト
        return NextResponse.redirect(new URL('/signin', request.url));
      }
    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.redirect(new URL('/signin', request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};