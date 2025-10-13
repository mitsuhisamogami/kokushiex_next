module Api
  class TestsController < ApplicationController
    skip_before_action :verify_csrf_token, only: [:index]

    # GET /api/tests
    def index
      tests = Test.includes(:test_sessions, :pass_mark).all
      render json: { tests: tests.map { |test| test_response(test) } }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    # 試験データをJSON用に整形するヘルパーメソッド
    def test_response(test)
      {
        id: test.id,
        year: test.year,
        questions_count: calculate_questions_count(test),
        pass_mark: pass_mark_response(test.pass_mark),
        created_at: test.created_at
      }
    end

    # 合格基準データを整形するヘルパーメソッド
    def pass_mark_response(pass_mark)
      return nil unless pass_mark

      {
        required_score: pass_mark.required_score,
        required_practical_score: pass_mark.required_practical_score,
        total_score: pass_mark.total_score
      }
    end

    # 問題数を計算するヘルパーメソッド
    def calculate_questions_count(test)
      test.test_sessions.sum { |session| session.questions.count }
    end
  end
end
