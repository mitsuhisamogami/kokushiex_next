require 'rails_helper'

RSpec.describe PassMark, type: :model do
  describe '関連付け' do
    it 'Testモデルに属する' do
      association = PassMark.reflect_on_association(:test)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be_falsey
    end
  end

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

    it 'required_scoreが必須である' do
      pass_mark = PassMark.new(required_practical_score: 41, total_score: 280)
      pass_mark.valid?
      expect(pass_mark.errors[:required_score]).to include("can't be blank")
    end

    it 'required_practical_scoreが必須である' do
      pass_mark = PassMark.new(required_score: 168, total_score: 280)
      pass_mark.valid?
      expect(pass_mark.errors[:required_practical_score]).to include("can't be blank")
    end

    it 'total_scoreが必須である' do
      pass_mark = PassMark.new(required_score: 168, required_practical_score: 41)
      pass_mark.valid?
      expect(pass_mark.errors[:total_score]).to include("can't be blank")
    end

    describe 'test_idの一意性' do
      let(:test) { create(:test) }
      let!(:pass_mark) { create(:pass_mark, test: test) }

      it '同じテストに対して重複する合格基準は作成できない' do
        duplicate_pass_mark = build(:pass_mark, test: test)
        expect(duplicate_pass_mark).not_to be_valid
        expect(duplicate_pass_mark.errors[:test_id]).to include('has already been taken')
      end

      it '異なるテストに対しては合格基準を作成できる' do
        another_test = create(:test, year: '第59回')
        another_pass_mark = build(:pass_mark, test: another_test)
        expect(another_pass_mark).to be_valid
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

    let(:test) { create(:test) }

    it '有効な属性で合格基準を作成できる' do
      pass_mark = PassMark.new(
        test: test,
        required_score: 168,
        required_practical_score: 41,
        total_score: 280
      )
      expect(pass_mark).to be_valid
    end

    it '合格基準データを保存できる' do
      pass_mark = PassMark.create!(
        test: test,
        required_score: 168,
        required_practical_score: 41,
        total_score: 280
      )
      expect(pass_mark.persisted?).to be true
      expect(pass_mark.required_score).to eq(168)
      expect(pass_mark.required_practical_score).to eq(41)
      expect(pass_mark.total_score).to eq(280)
    end

    it 'テストから合格基準を参照できる' do
      pass_mark = create(:pass_mark, test: test)
      expect(test.pass_mark).to eq(pass_mark)
    end

    it 'テストが削除されると関連する合格基準も削除される' do
      create(:pass_mark, test: test)
      expect {
        test.destroy
      }.to change(PassMark, :count).by(-1)
    end
  end

  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:pass_mark)).to be_valid
    end
  end
end
