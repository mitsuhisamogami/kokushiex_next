const nextJest = require('next/jest')

/** @type {import('jest').Config} */
const createJestConfig = nextJest({
  // Next.jsアプリケーションのパスを指定
  dir: './',
})

// Jestのカスタム設定
const config = {
  // テスト環境をjsdomに設定（ブラウザ環境をシミュレート）
  testEnvironment: 'jsdom',

  // セットアップファイルを指定
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],

  // テストファイルのパターンを指定
  testMatch: [
    '**/__tests__/**/*.(ts|tsx|js)',
    '**/*.(test|spec).(ts|tsx|js)'
  ],

  // カバレッジの設定
  collectCoverageFrom: [
    'app/**/*.{js,jsx,ts,tsx}',
    'components/**/*.{js,jsx,ts,tsx}',
    'contexts/**/*.{js,jsx,ts,tsx}',
    'lib/**/*.{js,jsx,ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
  ],

  // モジュール名のマッピング（パスエイリアスに対応）
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },

  // 変換の対象外ファイル
  transformIgnorePatterns: [
    '/node_modules/',
    '^.+\\.module\\.(css|sass|scss)$',
  ],

  // カバレッジのしきい値
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
}

// Next.jsの設定とマージしてエクスポート
module.exports = createJestConfig(config)