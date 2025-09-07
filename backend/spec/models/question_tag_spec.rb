require 'rails_helper'

RSpec.describe QuestionTag, type: :model do
  describe '関連付け' do
    it 'Questionモデルに属する' do
      association = QuestionTag.reflect_on_association(:question)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be_falsey
    end

    it 'Tagモデルに属する' do
      association = QuestionTag.reflect_on_association(:tag)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be_falsey
    end
  end

  describe 'バリデーション' do
    let(:question) { create(:question) }
    let(:tag) { create(:tag) }

    it 'question_idとtag_idの組み合わせが一意である' do
      create(:question_tag, question: question, tag: tag)

      duplicate_question_tag = build(:question_tag, question: question, tag: tag)
      expect(duplicate_question_tag).not_to be_valid
      expect(duplicate_question_tag.errors[:question_id]).to include('has already been taken')
    end

    it '異なる問題に同じタグを付けることができる' do
      another_question = create(:question)
      create(:question_tag, question: question, tag: tag)

      another_question_tag = build(:question_tag, question: another_question, tag: tag)
      expect(another_question_tag).to be_valid
    end

    it '同じ問題に異なるタグを付けることができる' do
      another_tag = create(:tag, name: 'another_tag')
      create(:question_tag, question: question, tag: tag)

      another_question_tag = build(:question_tag, question: question, tag: another_tag)
      expect(another_question_tag).to be_valid
    end
  end

  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:question_tag)).to be_valid
    end
  end
end
