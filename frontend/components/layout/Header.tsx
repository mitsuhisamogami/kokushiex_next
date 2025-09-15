'use client';

import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/contexts/auth-context";

// 将来的なリファクタリング案:
// const navItems = [
//   { href: "/", label: "トップ" },
//   { href: "/dashboard", label: "ダッシュボード" },
//   { href: "/practice", label: "過去問演習" },
//   { href: "/login", label: "ログイン" },
//   { href: "/guest", label: "ゲストログイン" },
// ];

export default function Header() {
  const { user, loading, logout, loginAsGuest } = useAuth();
  return (
    <header className="flex flex-wrap p-2 flex-col md:flex-row items-center bg-sky-100 sticky top-0 z-50">
        <div className="flex flex-row items-center gap-2">
            {/* 遷移先ができたらパスを修正 */}
            <Link
              className="flex title-font font-medium items-center text-gray-900 mb-2 md:mb-0"
              href="/"
            >
              <Image
                className="size-12"
                src="/logo.png"
                alt="Service Logo"
                width={48}
                height={48}
              />
              <p className="ml-3 text-xl">国試ex for PT</p>
            </Link>
        </div>
        {/* 遷移先ができたらパスを修正 */}
        <nav className="md:ml-auto flex flex-wrap items-center text-base justify-center">
            {/* 将来的にはnavItems配列をmapで展開する:
            {navItems.map((item) => (
              <Link
                key={item.label}
                href={item.href}
                className="mr-5 hover:text-orange-300 cursor-pointer"
              >
                {item.label}
              </Link>
            ))} */}
            <Link href="/" className="mr-5 hover:text-orange-300 cursor-pointer ">トップ</Link>
            {user && !user.is_guest && (
              <>
                <Link href="/dashboard" className="mr-5 hover:text-orange-300 cursor-pointer ">ダッシュボード</Link>
                <Link href="/practice" className="mr-5 hover:text-orange-300 cursor-pointer ">過去問演習</Link>
              </>
            )}

            {loading ? (
              <span className="mr-5">読み込み中...</span>
            ) : user ? (
              <div className="flex items-center space-x-4">
                <span className="mr-2">
                  {user.is_guest ? 'ゲストユーザー' : user.name || user.email}
                </span>
                <button
                  onClick={logout}
                  className="mr-5 hover:text-orange-300 cursor-pointer"
                >
                  ログアウト
                </button>
              </div>
            ) : (
              <>
                <Link href="/signin" className="mr-5 hover:text-orange-300 cursor-pointer ">ログイン</Link>
                <Link href="/signup" className="mr-5 hover:text-orange-300 cursor-pointer ">新規登録</Link>
                <button
                  onClick={loginAsGuest}
                  className="mr-5 hover:text-orange-300 cursor-pointer"
                >
                  ゲストログイン
                </button>
              </>
            )}
        </nav>
    </header>
  )
}