// 合格基準の型定義
export interface PassMark {
  required_score: number;
  required_practical_score: number;
  total_score: number;
}

// 試験の型定義
export interface Test {
  id: number;
  year: string;
  questions_count: number;
  pass_mark: PassMark | null;
  created_at: string;
}

// API レスポンスの型定義
export interface TestsResponse {
  tests: Test[];
}
