require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'バリデーション' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      QuestionTag.delete_all
      PassMark.delete_all
      Tag.delete_all
    end

    it '名前が必須であること' do
      tag = Tag.new
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end

    it '名前が一意であること' do
      Tag.create!(name: "解剖学")
      duplicate_tag = Tag.new(name: "解剖学")
      expect(duplicate_tag).not_to be_valid
      expect(duplicate_tag.errors[:name]).to include("has already been taken")
    end

    it '有効な名前でタグを作成できること' do
      tag = Tag.new(name: "生理学")
      expect(tag).to be_valid
    end
  end

  describe 'アソシエーション' do
    let(:tag) { Tag.create!(name: "テスト専用タグ") }

    before do
      # 重複を避けるため、テスト専用タグがあれば削除
      Tag.where(name: "テスト専用タグ").delete_all
    end

    it 'question_tagsとの関連を持つこと' do
      expect(tag).to respond_to(:question_tags)
    end

    it 'questionsとの関連を持つこと（through question_tags）' do
      expect(tag).to respond_to(:questions)
    end

    # 削除時の依存関係テスト（将来QuestionTagモデル実装後に有効になる）
    # it 'タグが削除されるとquestion_tagsも削除されること' do
    #   question_tag = tag.question_tags.create!(question: create(:question))
    #   expect { tag.destroy }.to change(QuestionTag, :count).by(-1)
    # end
  end

  describe 'スコープ' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      QuestionTag.delete_all
      PassMark.delete_all
      Tag.delete_all
      # 主要カテゴリ (id: 1-3)
      @major1 = Tag.create!(id: 1, name: "基礎医学")
      @major2 = Tag.create!(id: 2, name: "臨床医学")
      @major3 = Tag.create!(id: 3, name: "理学療法")

      # 共通科目 (id: 4-13)
      @common1 = Tag.create!(id: 4, name: "解剖学")
      @common2 = Tag.create!(id: 5, name: "生理学")
      @common3 = Tag.create!(id: 6, name: "運動学")
      @common4 = Tag.create!(id: 7, name: "病理学")
      @common5 = Tag.create!(id: 8, name: "衛生学")
      @common6 = Tag.create!(id: 9, name: "公衆衛生学")
      @common7 = Tag.create!(id: 10, name: "医学概論")
      @common8 = Tag.create!(id: 11, name: "臨床心理学")
      @common9 = Tag.create!(id: 12, name: "リハビリテーション医学")
      @common10 = Tag.create!(id: 13, name: "臨床医学大要")

      # 専門科目 (id: 14-26)
      @special1 = Tag.create!(id: 14, name: "理学療法概論")
      @special2 = Tag.create!(id: 15, name: "理学療法評価学")
      @special3 = Tag.create!(id: 16, name: "運動療法")
      @special4 = Tag.create!(id: 17, name: "物理療法")
      @special5 = Tag.create!(id: 18, name: "装具学")
      @special6 = Tag.create!(id: 19, name: "義肢学")
      @special7 = Tag.create!(id: 20, name: "日常生活活動")
      @special8 = Tag.create!(id: 21, name: "地域理学療法")
      @special9 = Tag.create!(id: 22, name: "理学療法研究法")
      @special10 = Tag.create!(id: 23, name: "神経系理学療法")
      @special11 = Tag.create!(id: 24, name: "筋骨格系理学療法")
      @special12 = Tag.create!(id: 25, name: "内部障害理学療法")
      @special13 = Tag.create!(id: 26, name: "発達理学療法")
    end

    describe '.major_categories' do
      it '主要カテゴリ（id: 1-3）のタグを返すこと' do
        major_tags = Tag.major_categories.order(:id)
        expect(major_tags.count).to eq(3)
        expect(major_tags).to include(@major1, @major2, @major3)
        expect(major_tags.pluck(:name)).to eq([ "基礎医学", "臨床医学", "理学療法" ])
      end
    end

    describe '.common_tags' do
      it '共通科目（id: 4-13）のタグを返すこと' do
        common_tags = Tag.common_tags.order(:id)
        expect(common_tags.count).to eq(10)
        expect(common_tags.first.name).to eq("解剖学")
        expect(common_tags.last.name).to eq("臨床医学大要")
      end
    end

    describe '.special_tags' do
      it '専門科目（id: 14-26）のタグを返すこと' do
        special_tags = Tag.special_tags.order(:id)
        expect(special_tags.count).to eq(13)
        expect(special_tags.first.name).to eq("理学療法概論")
        expect(special_tags.last.name).to eq("発達理学療法")
      end
    end
  end

  describe '基本機能' do
    before do
      # 外部キー制約を考慮して、子テーブルから順に削除
      QuestionTag.delete_all
      PassMark.delete_all
      Tag.delete_all
    end

    it '有効な属性でタグを作成できること' do
      tag = Tag.new(name: "解剖学")
      expect(tag).to be_valid
    end

    it 'タグデータを保存できること' do
      tag = Tag.create!(name: "生理学")
      expect(tag.persisted?).to be true
      expect(tag.name).to eq("生理学")
    end

    it 'タグ名で検索できること' do
      tag = Tag.create!(name: "運動学")
      found_tag = Tag.find_by(name: "運動学")
      expect(found_tag).to eq(tag)
    end
  end
end
