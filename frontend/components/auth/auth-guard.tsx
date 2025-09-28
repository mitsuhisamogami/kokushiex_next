'use client';

import { useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';

interface AuthGuardProps {
  children: ReactNode;
  redirectTo?: string;
}

export function AuthGuard({ children, redirectTo = '/signin' }: AuthGuardProps) {
  const { user, loading } = useAuth();
  const router = useRouter();

  // デバッグログ
  console.log('AuthGuard state:', { loading, user: !!user, userDetails: user });

  useEffect(() => {
    console.log('AuthGuard useEffect:', { loading, user: !!user });

    // ローディング中は何もしない
    if (loading) {
      console.log('Still loading, waiting...');
      return;
    }

    // ローディングが完了して、ユーザーが存在しない場合のみリダイレクト
    if (!loading && !user) {
      console.log('No user found, redirecting to:', redirectTo);
      router.push(redirectTo);
    } else if (!loading && user) {
      console.log('User authenticated, showing dashboard');
    }
  }, [loading, user, router, redirectTo]);

  // ローディング中の表示
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-900">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
          <p className="mt-4 text-slate-400">読み込み中...</p>
        </div>
      </div>
    );
  }

  // 未認証の場合は何も表示しない（リダイレクト処理はuseEffectで行う）
  if (!user) {
    return null;
  }

  // 認証済みの場合は子コンポーネントを表示
  return <>{children}</>;
}