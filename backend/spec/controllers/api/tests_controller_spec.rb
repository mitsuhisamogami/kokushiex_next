require 'rails_helper'

RSpec.describe Api::TestsController, type: :controller do
  before(:each) do
    Test.destroy_all
  end

  describe 'GET #index' do
    context '試験が存在する場合' do
      let!(:test1) { create(:test, year: "第58回") }
      let!(:test2) { create(:test, year: "第57回") }
      let!(:test3) { create(:test, year: "第56回") }

      # test1に関連データを作成
      let!(:pass_mark1) { create(:pass_mark, test: test1, required_score: 168, required_practical_score: 41, total_score: 280) }
      let!(:session1_morning) { create(:test_session, :morning, test: test1) }
      let!(:session1_afternoon) { create(:test_session, :afternoon, test: test1) }
      let!(:questions1) { create_list(:question, 5, test_session: session1_morning) }
      let!(:questions2) { create_list(:question, 5, test_session: session1_afternoon) }

      # test2に関連データを作成
      let!(:pass_mark2) { create(:pass_mark, test: test2) }
      let!(:session2) { create(:test_session, test: test2) }
      let!(:questions3) { create_list(:question, 3, test_session: session2) }

      it 'HTTPステータス200を返す' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'すべての試験を返す' do
        get :index
        json = JSON.parse(response.body)
        expect(json["tests"].length).to eq(3)
      end

      it '試験データが正しい構造で返される' do
        get :index
        json = JSON.parse(response.body)
        test = json["tests"].first

        expect(test).to include(
          "id",
          "year",
          "questions_count",
          "created_at"
        )
        expect(test["pass_mark"]).to be_present
      end

      it '問題数を正しく計算する' do
        get :index
        json = JSON.parse(response.body)
        test = json["tests"].find { |t| t["id"] == test1.id }
        expect(test["questions_count"]).to eq(10) # 5 + 5
      end

      it '合格基準が含まれる' do
        get :index
        json = JSON.parse(response.body)
        test = json["tests"].find { |t| t["id"] == test1.id }

        expect(test["pass_mark"]).to eq({
          "required_score" => 168,
          "required_practical_score" => 41,
          "total_score" => 280
        })
      end
    end

    context '試験が存在しない場合' do
      it 'HTTPステータス200を返す' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it '空の配列を返す' do
        get :index
        json = JSON.parse(response.body)
        expect(json["tests"]).to eq([])
      end
    end
  end
end
