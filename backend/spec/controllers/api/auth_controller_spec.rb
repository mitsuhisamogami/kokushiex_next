require 'rails_helper'

RSpec.describe Api::AuthController, type: :controller do
  describe 'POST #login' do
    let(:valid_credentials) do
      {
        email: 'test@example.com',
        password: 'password123'
      }
    end

    context '有効な認証情報の場合' do
      it 'JWTトークンを返すこと' do
        # TODO(human): ユーザー認証のロジックを実装する
        post :login, params: valid_credentials

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present
        expect(json_response['user']).to be_present
      end

      it '正しいユーザー情報を返すこと' do
        post :login, params: valid_credentials

        json_response = JSON.parse(response.body)
        expect(json_response['user']['email']).to eq(valid_credentials[:email])
      end
    end

    context '無効な認証情報の場合' do
      it '401エラーを返すこと' do
        invalid_credentials = { email: 'test@example.com', password: 'wrong_password' }
        post :login, params: invalid_credentials

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
      end
    end

    context '認証情報が不足している場合' do
      it '400エラーを返すこと' do
        incomplete_credentials = { email: 'test@example.com' }
        post :login, params: incomplete_credentials

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST #verify' do
    let(:valid_token) { JwtService.encode({ user_id: 1 }) }

    context '有効なトークンの場合' do
      before do
        request.headers['Authorization'] = "Bearer #{valid_token}"
      end

      it 'ユーザー情報を返すこと' do
        post :verify

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['user']).to be_present
        expect(json_response['valid']).to be true
      end
    end

    context '無効なトークンの場合' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
      end

      it '401エラーを返すこと' do
        post :verify

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['valid']).to be false
      end
    end

    context 'トークンが提供されていない場合' do
      it '401エラーを返すこと' do
        post :verify

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
