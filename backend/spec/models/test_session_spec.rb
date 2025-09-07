require 'rails_helper'

RSpec.describe TestSession, type: :model do
  describe '関連付け' do
    it 'Testモデルに属する' do
      association = TestSession.reflect_on_association(:test)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be_falsey
    end

    it 'Questionモデルを複数持つ（依存削除あり）' do
      association = TestSession.reflect_on_association(:questions)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'バリデーション' do
    it 'nameが必須である' do
      session = TestSession.new(name: nil, session_type: 'morning')
      session.valid?
      expect(session.errors[:name]).to include("can't be blank")
    end

    it 'session_typeが必須である' do
      session = TestSession.new(name: '午前', session_type: nil)
      session.valid?
      expect(session.errors[:session_type]).to include("can't be blank")
    end

    describe 'session_typeの一意性（test_idスコープ）' do
      before do
        # 外部キー制約を考慮して、子テーブルから順に削除
        Choice.delete_all
        Question.delete_all
        TestSession.delete_all
        Test.delete_all
      end

      let(:test) { create(:test) }
      let!(:morning_session) { create(:test_session, test: test, session_type: 'morning') }

      it '同じテストで異なるsession_typeは許可される' do
        afternoon_session = build(:test_session, test: test, session_type: 'afternoon')
        expect(afternoon_session).to be_valid
      end

      it '同じテストで重複するsession_typeは許可されない' do
        duplicate_session = build(:test_session, test: test, session_type: 'morning')
        expect(duplicate_session).not_to be_valid
        expect(duplicate_session.errors[:session_type]).to include('has already been taken')
      end

      it '異なるテストで同じsession_typeは許可される' do
        another_test = create(:test)
        another_morning_session = build(:test_session, test: another_test, session_type: 'morning')
        expect(another_morning_session).to be_valid
      end
    end
  end

  describe 'スコープ' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      Choice.delete_all
      Question.delete_all
      TestSession.delete_all
      Test.delete_all
    end

    let(:test) { create(:test) }
    let!(:morning_session) { create(:test_session, :morning, test: test) }
    let!(:afternoon_session) { create(:test_session, :afternoon, test: test) }

    describe '.morning' do
      it '午前のセッションのみを返す' do
        expect(TestSession.morning).to contain_exactly(morning_session)
      end
    end

    describe '.afternoon' do
      it '午後のセッションのみを返す' do
        expect(TestSession.afternoon).to contain_exactly(afternoon_session)
      end
    end
  end

  describe 'インスタンスメソッド' do
    describe '#morning?' do
      it '午前セッションの場合trueを返す' do
        session = build(:test_session, session_type: 'morning')
        expect(session.morning?).to be true
      end

      it '午前セッション以外の場合falseを返す' do
        session = build(:test_session, session_type: 'afternoon')
        expect(session.morning?).to be false
      end
    end

    describe '#afternoon?' do
      it '午後セッションの場合trueを返す' do
        session = build(:test_session, session_type: 'afternoon')
        expect(session.afternoon?).to be true
      end

      it '午後セッション以外の場合falseを返す' do
        session = build(:test_session, session_type: 'morning')
        expect(session.afternoon?).to be false
      end
    end
  end

  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:test_session)).to be_valid
    end

    it '有効なmorningトレイトを持つ' do
      session = build(:test_session, :morning)
      expect(session).to be_valid
      expect(session.session_type).to eq('morning')
      expect(session.name).to eq('午前')
    end

    it '有効なafternoonトレイトを持つ' do
      session = build(:test_session, :afternoon)
      expect(session).to be_valid
      expect(session.session_type).to eq('afternoon')
      expect(session.name).to eq('午後')
    end
  end
end
