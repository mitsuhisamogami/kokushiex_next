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

  // 保護されたパスの場合は軽量な認証チェックのみ実行
  if (protectedPaths.some(path => pathname.startsWith(path))) {
    // クッキーからトークンを取得（存在チェックのみ）
    const token = request.cookies.get('auth_token')?.value;

    // トークンがない場合のみリダイレクト
    if (!token) {
      return NextResponse.redirect(new URL('/signin', request.url));
    }

    // トークンが存在する場合は、詳細な検証はクライアントサイドに委譲
    // API通信は行わず、パフォーマンスを重視
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