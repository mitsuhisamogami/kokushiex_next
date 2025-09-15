require 'rails_helper'

RSpec.describe Api::GuestSessionsController, type: :controller do
  before(:each) do
    User.destroy_all
  end

  describe "POST #create" do
    context "正常なケース" do
      it "ゲストユーザーを作成してトークンを返す" do
        post :create

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["message"]).to eq("ゲストユーザーとしてログインしました")

        # ユーザー情報の確認
        user_data = json["data"]["user"]
        expect(user_data["is_guest"]).to be true
        expect(user_data["expires_at"]).to be_present
        expect(user_data["remaining_seconds"]).to be > 0
        expect(user_data["remaining_time"]).to be_present

        # トークンの確認
        expect(json["data"]["token"]).to be_present

        # データベースにユーザーが作成されているか確認
        user = User.find(user_data["id"])
        expect(user.is_guest).to be true
        expect(user.guest_expires_at).to be_present
      end
    end

    context "ゲストユーザー数が上限に達している場合" do
      it "エラーを返す" do
        # 200人の上限に達している状態をモック
        allow(User).to receive(:active_guest_count).and_return(200)

        post :create

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
        expect(json["message"]).to include("上限")
      end
    end
  end
end
