require 'rails_helper'

RSpec.describe Question, type: :model do
  describe '関連付け' do
    it 'TestSessionモデルに属する' do
      association = Question.reflect_on_association(:test_session)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be_falsey
    end

    it 'Choiceモデルを複数持つ（依存削除あり）' do
      association = Question.reflect_on_association(:choices)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'Active Storageで画像を添付できる' do
      question = Question.new
      expect(question).to respond_to(:image)
    end

    it 'QuestionTagモデルを複数持つ（依存削除あり）' do
      association = Question.reflect_on_association(:question_tags)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'Tagモデルと多対多の関係を持つ（through question_tags）' do
      association = Question.reflect_on_association(:tags)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:question_tags)
    end
  end

  describe 'バリデーション' do
    it 'contentが必須である' do
      question = Question.new(content: nil, question_number: 1)
      question.valid?
      expect(question.errors[:content]).to include("can't be blank")
    end

    it 'question_numberが必須である' do
      question = Question.new(content: '問題文', question_number: nil)
      question.valid?
      expect(question.errors[:question_number]).to include("can't be blank")
    end

    it 'question_numberが整数である' do
      question = Question.new(content: '問題文', question_number: 1.5)
      question.valid?
      expect(question.errors[:question_number]).to include('must be an integer')
    end

    it 'question_numberが0より大きい' do
      question = Question.new(content: '問題文', question_number: 0)
      question.valid?
      expect(question.errors[:question_number]).to include('must be greater than 0')
    end

    describe 'question_numberの一意性（test_session_idスコープ）' do
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
      let(:test_session) { create(:test_session, test: test) }
      let!(:question1) { create(:question, test_session: test_session, question_number: 1) }

      it '同じテストセッションで重複するquestion_numberは許可されない' do
        duplicate_question = build(:question, test_session: test_session, question_number: 1)
        expect(duplicate_question).not_to be_valid
        expect(duplicate_question.errors[:question_number]).to include('has already been taken')
      end

      it '異なるテストセッションで同じquestion_numberは許可される' do
        another_session = create(:test_session, test: test, session_type: 'afternoon')
        another_question = build(:question, test_session: another_session, question_number: 1)
        expect(another_question).to be_valid
      end
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

    let(:test_session) { create(:test_session) }
    let!(:question1) { create(:question, test_session: test_session, question_number: 2) }
    let!(:question2) { create(:question, test_session: test_session, question_number: 1) }
    let!(:question3) { create(:question, test_session: test_session, question_number: 3) }

    describe '.ordered' do
      it 'question_number順で問題を返す' do
        expect(Question.ordered).to eq([ question2, question1, question3 ])
      end
    end

    describe '.with_choices' do
      before do
        create(:choice, question: question1)
      end

      it '選択肢を含めて取得する' do
        result = Question.with_choices.first
        expect(result.association(:choices)).to be_loaded
      end
    end

    describe '.with_images' do
      it '画像添付を含めて取得する' do
        result = Question.with_images.first
        expect(result.association(:image_attachment)).to be_loaded
      end
    end
  end

  describe 'インスタンスメソッド' do
    let(:question) { create(:question) }

    describe '#correct_choice' do
      context '正解の選択肢がある場合' do
        let!(:correct_choice) { create(:choice, question: question, is_correct: true, option_number: 1) }
        let!(:incorrect_choice) { create(:choice, question: question, is_correct: false, option_number: 2) }

        it '正解の選択肢を返す' do
          expect(question.correct_choice).to eq(correct_choice)
        end
      end

      context '正解の選択肢がない場合' do
        let!(:choice) { create(:choice, question: question, is_correct: false) }

        it 'nilを返す' do
          expect(question.correct_choice).to be_nil
        end
      end
    end

    describe '#multiple_choice?' do
      context '正解が1つの場合' do
        let!(:correct_choice) { create(:choice, question: question, is_correct: true, option_number: 1) }
        let!(:incorrect_choice) { create(:choice, question: question, is_correct: false, option_number: 2) }

        it 'falseを返す' do
          expect(question.multiple_choice?).to be false
        end
      end

      context '正解が複数の場合' do
        let!(:correct_choice1) { create(:choice, question: question, is_correct: true, option_number: 1) }
        let!(:correct_choice2) { create(:choice, question: question, is_correct: true, option_number: 2) }

        it 'trueを返す' do
          expect(question.multiple_choice?).to be true
        end
      end

      context '正解がない場合' do
        let!(:choice) { create(:choice, question: question, is_correct: false) }

        it 'falseを返す' do
          expect(question.multiple_choice?).to be false
        end
      end
    end

    describe '#has_image?' do
      context '画像が添付されている場合' do
        before do
          question.image.attach(
            io: StringIO.new('dummy'),
            filename: 'test.png',
            content_type: 'image/png'
          )
        end

        it 'trueを返す' do
          expect(question.has_image?).to be true
        end
      end

      context '画像が添付されていない場合' do
        it 'falseを返す' do
          expect(question.has_image?).to be false
        end
      end
    end
  end

  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:question)).to be_valid
    end
  end
end
