'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/contexts/auth-context';

export default function SignInPage() {
  const router = useRouter();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // TODO(human): フォームバリデーションとエラー処理を実装
    // 1. メールフォーマットの検証
    // 2. パスワードの最小長チェック（8文字）
    // 3. loginを呼び出してエラーをキャッチ
    // 4. 成功時は router.push('/') でホームにリダイレクト
    // 5. エラー時は適切なメッセージを setError で設定
    try{
      setIsLoading(true);
      await login(email, password);
      router.push('/dashboard');
    }
    catch(error){
      setError(error instanceof Error ? error.message : 'サインインに失敗しました');
      console.error('サインインに失敗しました:', error);
    }
    finally{
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-900 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-slate-200">
            アカウントにサインイン
          </h2>
          <p className="mt-2 text-center text-sm text-slate-400">
            または{' '}
            <Link href="/signup" className="font-medium text-blue-400 hover:text-blue-300">
              新規アカウントを作成
            </Link>
          </p>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <input type="hidden" name="remember" value="true" />
          <div className="rounded-md shadow-sm -space-y-px">
            <div>
              <label htmlFor="email-address" className="sr-only">
                メールアドレス
              </label>
              <input
                id="email-address"
                name="email"
                type="email"
                autoComplete="email"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-slate-600 placeholder-slate-400 text-slate-200 bg-slate-800 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm autofill:bg-slate-800 autofill:text-slate-200 autofill:shadow-[inset_0_0_0px_1000px_rgb(30_41_59)] autofill:[-webkit-text-fill-color:rgb(226_232_240)]"
                placeholder="メールアドレス"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div>
              <label htmlFor="password" className="sr-only">
                パスワード
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-slate-600 placeholder-slate-400 text-slate-200 bg-slate-800 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm autofill:bg-slate-800 autofill:text-slate-200 autofill:shadow-[inset_0_0_0px_1000px_rgb(30_41_59)] autofill:[-webkit-text-fill-color:rgb(226_232_240)]"
                placeholder="パスワード"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          </div>

          {error && (
            <div className="rounded-md bg-red-900/20 border border-red-800/50 p-4">
              <div className="flex">
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-red-300">{error}</h3>
                </div>
              </div>
            </div>
          )}

          <div>
            <button
              type="submit"
              disabled={isLoading}
              className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-lg font-semibold rounded-full text-white bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg hover:shadow-blue-500/25 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-offset-slate-900 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0"
            >
              {isLoading ? 'サインイン中...' : 'サインイン'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}