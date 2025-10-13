'use client';

import React from 'react';
import type { Test } from "@/types/test";

interface TestSelectButtonProps {
  test: Test;
  className?: string;
}

export function TestSelectButton({
  test,
  className = ''
}: TestSelectButtonProps) {
  const handleClick = () => {
    // TODO: 試験詳細ページへの遷移を実装
    console.log("Test clicked:", test.id);
    // 実装時: import { useRouter } from 'next/navigation';
    // const router = useRouter();
    // router.push(`/tests/${test.id}`);
  };

  const baseClasses = 'w-full px-6 py-4 text-center font-semibold text-gray-700 bg-blue-50 rounded-lg border-2 border-blue-200 hover:bg-blue-100 hover:border-blue-300 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2';

  return (
    <button
      type="button"
      onClick={handleClick}
      className={`${baseClasses} ${className}`}
    >
      {test.year}
    </button>
  );
}
