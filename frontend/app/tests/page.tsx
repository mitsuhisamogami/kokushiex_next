import { TestSelectButton } from "@/components/tests/TestSelectButton";
import type { TestsResponse } from "@/types/test";

// 動的レンダリングを強制（APIからデータを取得するため）
export const dynamic = 'force-dynamic';

async function getTests(): Promise<TestsResponse> {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";

  try {
    const res = await fetch(`${apiUrl}/api/tests`, {
      cache: "no-store", // 常に最新データを取得
    });

    if (!res.ok) {
      throw new Error("Failed to fetch tests");
    }

    return res.json();
  } catch (error) {
    console.error("Error fetching tests:", error);
    return { tests: [] };
  }
}

export default async function TestsPage() {
  const data = await getTests();
  const tests = data.tests;

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h2 className="text-2xl font-bold mb-2 flex items-center gap-2">
          <span className="text-blue-600">📅</span>
          年度から選択
        </h2>
      </div>

      {tests.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-muted-foreground">試験データがありません</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {tests.map((test) => (
            <TestSelectButton
              key={test.id}
              test={test}
            />
          ))}
        </div>
      )}
    </div>
  );
}
