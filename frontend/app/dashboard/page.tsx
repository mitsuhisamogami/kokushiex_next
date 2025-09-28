'use client';

import { useAuth } from '@/contexts/auth-context';
import { DashboardCard } from '@/components/dashboard/DashboardCard';
import { RecentTestList } from '@/components/dashboard/RecentTestList';
import { QuickActionButtons } from '@/components/dashboard/QuickActionButtons';

export default function Dashboard() {
  const { user } = useAuth();

  // モックデータ（後でAPIから取得）
  const stats = {
    totalTests: 12,
    passRate: 75,
    studyTime: 45,
    averageScore: 82,
  };

  const recentResults = [
    {
      id: 1,
      testName: '第58回理学療法士国家試験 午前',
      score: 85,
      totalQuestions: 100,
      passed: true,
      completedAt: '2024-09-27T10:30:00',
    },
    {
      id: 2,
      testName: '第57回理学療法士国家試験 午後',
      score: 72,
      totalQuestions: 100,
      passed: false,
      completedAt: '2024-09-26T14:20:00',
    },
    {
      id: 3,
      testName: '第58回理学療法士国家試験 午後',
      score: 90,
      totalQuestions: 100,
      passed: true,
      completedAt: '2024-09-25T09:15:00',
    },
  ];

  const quickActions = [
    {
      label: '新しい試験を開始',
      description: '過去問から試験を選んで挑戦',
      href: '/tests',
      icon: '📝',
      variant: 'primary' as const,
    },
    {
      label: '学習履歴',
      description: '詳細な成績とグラフを確認',
      href: '/history',
      icon: '📊',
    },
    {
      label: 'プロフィール設定',
      description: 'アカウント情報を管理',
      href: '/profile',
      icon: '⚙️',
    },
  ];

  return (
    <div className="min-h-screen bg-slate-900">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* ヘッダー */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-slate-100 mb-2">ダッシュボード</h1>
          <p className="text-slate-400">
            ようこそ、{user?.name || user?.email || 'ゲスト'}さん
          </p>
        </div>

        {/* 統計カード */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <DashboardCard
            title="受験回数"
            value={stats.totalTests}
            subtitle="総試験数"
            trend={{ value: 20, isPositive: true }}
          />
          <DashboardCard
            title="平均点"
            value={stats.averageScore}
            subtitle="直近10回の平均"
            trend={{ value: 3, isPositive: false }}
          />
          <DashboardCard
            title="合格率"
            value={`${stats.passRate}%`}
            subtitle="全体の合格率"
            trend={{ value: 5, isPositive: true }}
          />
          <DashboardCard
            title="学習時間"
            value={`${stats.studyTime}h`}
            subtitle="今月の合計"
            trend={{ value: 15, isPositive: true }}
          />
        </div>

        {/* メインコンテンツエリア */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* 最近の試験結果 */}
          <div className="lg:col-span-2">
            <DashboardCard title="最近の試験結果">
              <RecentTestList
                results={recentResults}
                onViewDetails={(id) => console.log('View details:', id)}
              />
            </DashboardCard>
          </div>

          {/* お知らせ・通知 */}
          <div>
            <DashboardCard title="お知らせ" subtitle="最新の情報">
              <div className="space-y-3">
                <div className="p-3 bg-blue-900/20 border border-blue-700 rounded-lg">
                  <p className="text-sm text-blue-300">新しい過去問が追加されました</p>
                  <p className="text-xs text-slate-400 mt-1">2024/09/28</p>
                </div>
                <div className="p-3 bg-green-900/20 border border-green-700 rounded-lg">
                  <p className="text-sm text-green-300">システムメンテナンス完了</p>
                  <p className="text-xs text-slate-400 mt-1">2024/09/27</p>
                </div>
              </div>
            </DashboardCard>
          </div>
        </div>

        {/* クイックアクション */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-slate-100 mb-4">クイックアクション</h2>
          <QuickActionButtons actions={quickActions} />
        </div>
      </div>
    </div>
  );
}