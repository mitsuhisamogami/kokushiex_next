require 'rails_helper'

RSpec.describe AuthorizationService do
  describe '#permit?' do
    context 'ゲストユーザー' do
      let(:guest_user) { create(:user, role: :guest) }
      let(:service) { described_class.new(guest_user) }

      it '試験閲覧が可能' do
        expect(service.permit?(:view_tests)).to be true
      end

      it '試験受験が可能' do
        expect(service.permit?(:take_tests)).to be true
      end

      it '成績保存は不可' do
        expect(service.permit?(:save_scores)).to be false
      end

      it '履歴閲覧は不可' do
        expect(service.permit?(:view_history)).to be false
      end

      it 'プロフィール編集は不可' do
        expect(service.permit?(:edit_profile)).to be false
      end

      it '管理機能は不可' do
        expect(service.permit?(:admin_features)).to be false
      end
    end

    context '通常ユーザー' do
      let(:regular_user) { create(:user, role: :regular) }
      let(:service) { described_class.new(regular_user) }

      it '試験閲覧が可能' do
        expect(service.permit?(:view_tests)).to be true
      end

      it '試験受験が可能' do
        expect(service.permit?(:take_tests)).to be true
      end

      it '成績保存が可能' do
        expect(service.permit?(:save_scores)).to be true
      end

      it '履歴閲覧が可能' do
        expect(service.permit?(:view_history)).to be true
      end

      it 'プロフィール編集が可能' do
        expect(service.permit?(:edit_profile)).to be true
      end

      it '管理機能は不可' do
        expect(service.permit?(:admin_features)).to be false
      end
    end

    context '管理者ユーザー' do
      let(:admin_user) { create(:user, role: :admin) }
      let(:service) { described_class.new(admin_user) }

      it '試験閲覧が可能' do
        expect(service.permit?(:view_tests)).to be true
      end

      it '試験受験が可能' do
        expect(service.permit?(:take_tests)).to be true
      end

      it '成績保存が可能' do
        expect(service.permit?(:save_scores)).to be true
      end

      it '履歴閲覧が可能' do
        expect(service.permit?(:view_history)).to be true
      end

      it 'プロフィール編集が可能' do
        expect(service.permit?(:edit_profile)).to be true
      end

      it '管理機能が可能' do
        expect(service.permit?(:admin_features)).to be true
      end
    end

    context 'nilユーザー' do
      let(:service) { described_class.new(nil) }

      it 'すべての権限が不可' do
        expect(service.permit?(:view_tests)).to be false
        expect(service.permit?(:take_tests)).to be false
        expect(service.permit?(:save_scores)).to be false
        expect(service.permit?(:view_history)).to be false
        expect(service.permit?(:edit_profile)).to be false
        expect(service.permit?(:admin_features)).to be false
      end
    end

    context '未定義のアクション' do
      let(:user) { create(:user, role: :regular) }
      let(:service) { described_class.new(user) }

      it 'falseを返す' do
        expect(service.permit?(:undefined_action)).to be false
      end
    end
  end

  describe '#authorize!' do
    let(:user) { create(:user, role: :guest) }
    let(:service) { described_class.new(user) }

    context '権限がある場合' do
      it '例外を発生させない' do
        expect { service.authorize!(:view_tests) }.not_to raise_error
      end

      it 'trueを返す' do
        expect(service.authorize!(:view_tests)).to be true
      end
    end

    context '権限がない場合' do
      it 'AuthorizationService::UnauthorizedErrorを発生させる' do
        expect { service.authorize!(:save_scores) }
          .to raise_error(AuthorizationService::UnauthorizedError)
      end

      it '適切なエラーメッセージを含む' do
        expect { service.authorize!(:save_scores) }
          .to raise_error(AuthorizationService::UnauthorizedError) do |error|
            expect(error.message).to eq 'この操作を実行する権限がありません。'
            expect(error.action).to eq :save_scores
            expect(error.required_role).to eq :regular
          end
      end
    end
  end

  describe '#required_role_for' do
    let(:service) { described_class.new(nil) }

    it '各アクションの必要ロールを返す' do
      expect(service.required_role_for(:view_tests)).to eq :guest
      expect(service.required_role_for(:take_tests)).to eq :guest
      expect(service.required_role_for(:save_scores)).to eq :regular
      expect(service.required_role_for(:view_history)).to eq :regular
      expect(service.required_role_for(:edit_profile)).to eq :regular
      expect(service.required_role_for(:admin_features)).to eq :admin
    end

    it '未定義のアクションにはnilを返す' do
      expect(service.required_role_for(:undefined_action)).to be_nil
    end
  end

  describe '#role_hierarchy' do
    let(:service) { described_class.new(nil) }

    it '権限階層を正しく判定する' do
      expect(service.send(:role_hierarchy, :guest)).to eq 0
      expect(service.send(:role_hierarchy, :regular)).to eq 1
      expect(service.send(:role_hierarchy, :admin)).to eq 2
    end
  end
end
