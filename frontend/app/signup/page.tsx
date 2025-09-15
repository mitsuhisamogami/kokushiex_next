'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/contexts/auth-context';

export default function SignUpPage() {
  const router = useRouter();
  const { register } = useAuth();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    passwordConfirmation: '',
    name: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isLoading, setIsLoading] = useState(false);

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    // メールバリデーション
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(formData.email)) {
      newErrors.email = '有効なメールアドレスを入力してください';
    }

    // パスワードバリデーション
    if (formData.password.length < 8) {
      newErrors.password = 'パスワードは8文字以上で入力してください';
    }

    // パスワード確認
    if (formData.password !== formData.passwordConfirmation) {
      newErrors.passwordConfirmation = 'パスワードが一致しません';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsLoading(true);
    try {
      await register(
        formData.email,
        formData.password,
        formData.passwordConfirmation,
        formData.name || undefined
      );
      router.push('/');
    } catch (error) {
      setErrors({
        submit: error instanceof Error ? error.message : '登録に失敗しました',
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    // フィールド変更時にエラーをクリア
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-900 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-slate-200">
            新規アカウント作成
          </h2>
          <p className="mt-2 text-center text-sm text-slate-400">
            または{' '}
            <Link href="/signin" className="font-medium text-blue-400 hover:text-blue-300">
              既存のアカウントでサインイン
            </Link>
          </p>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="space-y-4">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-slate-300">
                名前（任意）
              </label>
              <input
                id="name"
                name="name"
                type="text"
                autoComplete="name"
                className="mt-1 appearance-none relative block w-full px-3 py-2 border border-slate-600 placeholder-slate-400 text-slate-200 bg-slate-800 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm autofill:bg-slate-800 autofill:text-slate-200 autofill:shadow-[inset_0_0_0px_1000px_rgb(30_41_59)] autofill:[-webkit-text-fill-color:rgb(226_232_240)]"
                placeholder="山田 太郎"
                value={formData.name}
                onChange={handleChange}
              />
            </div>

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-slate-300">
                メールアドレス
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                className={`mt-1 appearance-none relative block w-full px-3 py-2 border ${
                  errors.email ? 'border-red-500' : 'border-slate-600'
                } placeholder-slate-400 text-slate-200 bg-slate-800 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm autofill:bg-slate-800 autofill:text-slate-200 autofill:shadow-[inset_0_0_0px_1000px_rgb(30_41_59)] autofill:[-webkit-text-fill-color:rgb(226_232_240)]`}
                placeholder="email@example.com"
                value={formData.email}
                onChange={handleChange}
              />
              {errors.email && (
                <p className="mt-1 text-sm text-red-400">{errors.email}</p>
              )}
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-slate-300">
                パスワード
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="new-password"
                required
                className={`mt-1 appearance-none relative block w-full px-3 py-2 border ${
                  errors.password ? 'border-red-500' : 'border-slate-600'
                } placeholder-slate-400 text-slate-200 bg-slate-800 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm autofill:bg-slate-800 autofill:text-slate-200 autofill:shadow-[inset_0_0_0px_1000px_rgb(30_41_59)] autofill:[-webkit-text-fill-color:rgb(226_232_240)]`}
                placeholder="8文字以上"
                value={formData.password}
                onChange={handleChange}
              />
              {errors.password && (
                <p className="mt-1 text-sm text-red-400">{errors.password}</p>
              )}
            </div>

            <div>
              <label htmlFor="passwordConfirmation" className="block text-sm font-medium text-slate-300">
                パスワード（確認）
              </label>
              <input
                id="passwordConfirmation"
                name="passwordConfirmation"
                type="password"
                autoComplete="new-password"
                required
                className={`mt-1 appearance-none relative block w-full px-3 py-2 border ${
                  errors.passwordConfirmation ? 'border-red-500' : 'border-slate-600'
                } placeholder-slate-400 text-slate-200 bg-slate-800 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm autofill:bg-slate-800 autofill:text-slate-200 autofill:shadow-[inset_0_0_0px_1000px_rgb(30_41_59)] autofill:[-webkit-text-fill-color:rgb(226_232_240)]`}
                placeholder="パスワードを再入力"
                value={formData.passwordConfirmation}
                onChange={handleChange}
              />
              {errors.passwordConfirmation && (
                <p className="mt-1 text-sm text-red-400">{errors.passwordConfirmation}</p>
              )}
            </div>
          </div>

          {errors.submit && (
            <div className="rounded-md bg-red-900/20 border border-red-800/50 p-4">
              <div className="flex">
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-red-300">{errors.submit}</h3>
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
              {isLoading ? '作成中...' : 'アカウント作成'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}