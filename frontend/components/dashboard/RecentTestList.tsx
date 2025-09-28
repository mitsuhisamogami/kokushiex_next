'use client';

interface TestResult {
  id: number;
  testName: string;
  score: number;
  totalQuestions: number;
  passed: boolean;
  completedAt: string;
}

interface RecentTestListProps {
  results: TestResult[];
  onViewDetails?: (id: number) => void;
}

export function RecentTestList({ results, onViewDetails }: RecentTestListProps) {
  // TODO(human): 試験結果リストのレンダリングロジックを実装
  // 1. 結果がない場合の空状態表示
  // 2. 各結果項目の表示（試験名、スコア、合否バッジ、日時）
  // 3. クリック可能な詳細表示ボタン
  // ヒント: results.map()を使って各結果をレンダリング
  if (results.length === 0) {
    return (
      <div className="text-center py-8 text-slate-400">
        まだ試験結果がありません
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {results.map((result) => (
        <div
          key={result.id}
          className="flex items-center justify-between p-4 bg-slate-800/50 rounded-lg border border-slate-700 hover:border-slate-600 transition-colors"
        >
          <div className="flex-1">
            <h4 className="font-medium text-slate-200">{result.testName}</h4>
            <div className="flex items-center gap-4 mt-1">
              <span className="text-sm text-slate-400">
                {new Date(result.completedAt).toLocaleDateString('ja-JP')}
              </span>
              <span className="text-sm text-slate-300">
                {result.score}/{result.totalQuestions}問
              </span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <span
              className={`px-3 py-1 rounded-full text-xs font-medium ${
                result.passed
                  ? 'bg-green-900/50 text-green-300 border border-green-700'
                  : 'bg-red-900/50 text-red-300 border border-red-700'
              }`}
            >
              {result.passed ? '合格' : '不合格'}
            </span>

            {onViewDetails && (
              <button
                onClick={() => onViewDetails(result.id)}
                className="px-3 py-1 text-sm text-blue-400 hover:text-blue-300 transition-colors"
              >
                詳細 →
              </button>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}