require 'rails_helper'

RSpec.describe Test, type: :model do
  describe 'バリデーション' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      QuestionTag.delete_all
      PassMark.delete_all
      Choice.delete_all
      Question.delete_all
      TestSession.delete_all
      Test.delete_all
    end

    it '年度が必須であること' do
      test = Test.new
      expect(test).not_to be_valid
      expect(test.errors[:year]).to include("can't be blank")
    end

    it '年度が一意であること' do
      Test.create!(year: "第58回")
      duplicate_test = Test.new(year: "第58回")
      expect(duplicate_test).not_to be_valid
      expect(duplicate_test.errors[:year]).to include("has already been taken")
    end
  end

  describe 'スコープ' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      QuestionTag.delete_all
      PassMark.delete_all
      Choice.delete_all
      Question.delete_all
      TestSession.delete_all
      Test.delete_all
      @test1 = Test.create!(year: "第58回", created_at: 1.day.ago)
      @test2 = Test.create!(year: "第57回", created_at: 2.days.ago)
      @test3 = Test.create!(year: "第56回", created_at: 3.days.ago)
    end

    describe '.recent' do
      it '作成日時の降順でテストを返す' do
        expect(Test.recent.pluck(:year)).to eq([ "第58回", "第57回", "第56回" ])
      end
    end

    describe '.by_year' do
      it '指定した年度のテストを返す' do
        expect(Test.by_year("第58回").first).to eq(@test1)
      end

      it '該当する年度がない場合は空の配列を返す' do
        expect(Test.by_year("第59回")).to be_empty
      end
    end
  end

  describe '基本機能' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      QuestionTag.delete_all
      PassMark.delete_all
      Choice.delete_all
      Question.delete_all
      TestSession.delete_all
      Test.delete_all
    end

    it '有効な属性でテストを作成できる' do
      test = Test.new(year: "第58回")
      expect(test).to be_valid
    end

    it 'テストデータを保存できる' do
      test = Test.create!(year: "第58回")
      expect(test.persisted?).to be true
      expect(test.year).to eq("第58回")
    end
  end
end
