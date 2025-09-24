require 'rails_helper'

RSpec.describe Api::AuthController, type: :controller do
  describe 'POST #register' do
    context 'with valid parameters' do
      let(:email) { 'newuser@example.com' }
      let(:valid_params) do
        {
          email: email,
          password: 'password123',
          password_confirmation: 'password123',
          name: 'Test User'
        }
      end

      it 'creates a new user' do
        expect {
          post :register, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns user data and token' do
        post :register, params: valid_params
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json).to have_key('user')
        expect(json).to have_key('token')
        expect(json['user']['email']).to eq(email)
        expect(json['user']['is_guest']).to be_falsey
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post :register, params: { email: 'invalid', password: '123' }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key('errors')
      end
    end
  end

  describe 'POST #login' do
    let!(:user) { create(:user, password: 'password123', is_guest: false) }

    context 'with valid credentials' do
      it 'returns user data and token' do
        post :login, params: { email: user.email, password: 'password123' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('user')
        expect(json).to have_key('token')
        expect(json['user']['email']).to eq(user.email)
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized error' do
        post :login, params: { email: user.email, password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Invalid email or password')
      end
    end
  end

  describe 'GET #me' do
    let!(:user) { create(:user, is_guest: false) }
    let(:token) { controller.send(:encode_jwt, { user_id: user.id }) }

    context 'with valid token' do
      it 'returns current user data' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :me
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq(user.email)
      end
    end

    context 'without token' do
      it 'returns unauthorized error' do
        get :me
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized error' do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :me
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #logout' do
    let!(:user) { create(:user, is_guest: false) }
    let(:token) { controller.send(:encode_jwt, { user_id: user.id }) }
    let(:csrf_token) { CsrfTokenService.generate }

    context 'with valid CSRF token' do
      it 'returns success message' do
        request.headers['Authorization'] = "Bearer #{token}"
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = csrf_token

        post :logout

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to include('Logged out successfully')
      end
    end

    context 'without CSRF token' do
      it 'returns 403 forbidden error' do
        request.headers['Authorization'] = "Bearer #{token}"

        post :logout

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid CSRF token')
      end
    end

    context 'with invalid CSRF token' do
      it 'returns 403 forbidden error' do
        request.headers['Authorization'] = "Bearer #{token}"
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = 'invalid_token'

        post :logout

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid CSRF token')
      end
    end
  end

  describe 'GET #verify' do
    let!(:user) { create(:user, is_guest: false) }
    let(:token) { controller.send(:encode_jwt, { user_id: user.id }) }

    context 'with valid token' do
      it 'returns user data and valid status' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :verify
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['valid']).to be true
        expect(json['user']['email']).to eq(user.email)
      end
    end

    context 'with invalid token' do
      it 'returns invalid status' do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :verify
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['valid']).to be false
      end
    end
  end
end
