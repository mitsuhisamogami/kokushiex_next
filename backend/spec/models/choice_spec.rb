require 'rails_helper'

RSpec.describe Choice, type: :model do
  describe '関連付け' do
    it 'Questionモデルに属する' do
      association = Choice.reflect_on_association(:question)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be_falsey
    end
  end

  describe 'バリデーション' do
    it 'contentが必須である' do
      choice = Choice.new(content: nil, option_number: 1)
      choice.valid?
      expect(choice.errors[:content]).to include("can't be blank")
    end

    it 'option_numberが必須である' do
      choice = Choice.new(content: '選択肢', option_number: nil)
      choice.valid?
      expect(choice.errors[:option_number]).to include("can't be blank")
    end

    it 'option_numberが1から5の範囲内である' do
      choice = Choice.new(content: '選択肢', option_number: 0)
      choice.valid?
      expect(choice.errors[:option_number]).to include('must be in 1..5')

      choice = Choice.new(content: '選択肢', option_number: 6)
      choice.valid?
      expect(choice.errors[:option_number]).to include('must be in 1..5')

      choice = Choice.new(content: '選択肢', option_number: 3)
      choice.valid?
      expect(choice.errors[:option_number]).to be_empty
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
    end

    let(:question) { create(:question) }
    let!(:choice1) { create(:choice, question: question, option_number: 2) }
    let!(:choice2) { create(:choice, question: question, option_number: 1) }
    let!(:choice3) { create(:choice, question: question, option_number: 3) }

    describe '.ordered' do
      it 'option_number順で選択肢を返す' do
        expect(question.choices.ordered).to eq([ choice2, choice1, choice3 ])
      end
    end

    describe '.correct' do
      let!(:correct_choice) { create(:choice, question: question, option_number: 4, is_correct: true) }
      let!(:incorrect_choice) { create(:choice, question: question, option_number: 5, is_correct: false) }

      it '正解の選択肢のみを返す' do
        expect(question.choices.correct).to contain_exactly(correct_choice)
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

    let(:question) { create(:question) }

    it '有効な属性で選択肢を作成できる' do
      choice = Choice.new(
        question: question,
        content: '選択肢1',
        option_number: 1,
        is_correct: false
      )
      expect(choice).to be_valid
    end

    it 'is_correctのデフォルト値がfalseである' do
      choice = Choice.new(
        question: question,
        content: '選択肢',
        option_number: 1
      )
      expect(choice.is_correct).to be false
    end

    it '同じ問題内でoption_numberが一意である（データベース制約）' do
      create(:choice, question: question, option_number: 1)
      duplicate_choice = build(:choice, question: question, option_number: 1)

      expect {
        duplicate_choice.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it '異なる問題で同じoption_numberを使用できる' do
      another_question = create(:question)
      choice1 = create(:choice, question: question, option_number: 1)
      choice2 = build(:choice, question: another_question, option_number: 1)

      expect(choice2).to be_valid
    end
  end

  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:choice)).to be_valid
    end

    it '正解の選択肢を作成できる' do
      choice = build(:choice, is_correct: true)
      expect(choice.is_correct).to be true
    end

    it '不正解の選択肢を作成できる' do
      choice = build(:choice, is_correct: false)
      expect(choice.is_correct).to be false
    end
  end
end
