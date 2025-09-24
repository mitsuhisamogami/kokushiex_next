require 'rails_helper'

RSpec.describe CsrfProtectable, type: :controller do
  # テスト用のダミーコントローラーを作成
  controller(ApplicationController) do
    include CsrfProtectable

    def create
      render json: { message: 'Created successfully' }, status: :created
    end

    def update
      render json: { message: 'Updated successfully' }, status: :ok
    end

    def show
      render json: { message: 'Show action' }, status: :ok
    end

    def destroy
      render json: { message: 'Deleted successfully' }, status: :ok
    end

    def custom_logout
      render json: { message: 'Logged out successfully' }, status: :ok
    end
  end

  before do
    routes.draw do
      post 'create' => 'anonymous#create'
      put 'update' => 'anonymous#update'
      get 'show' => 'anonymous#show'
      delete 'destroy' => 'anonymous#destroy'
      get 'custom_logout' => 'anonymous#custom_logout'
    end
  end

  describe 'CSRF保護の自動実行' do
    let(:csrf_token) { CsrfTokenService.generate }

    context 'POST リクエストの場合' do
      it '有効なCSRFトークンでアクセス成功すること' do
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = csrf_token

        post :create

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Created successfully')
      end

      it '無効なCSRFトークンで403エラーを返すこと' do
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = 'invalid_token'

        post :create

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid CSRF token')
      end

      it 'CSRFトークンが未設定で403エラーを返すこと' do
        post :create

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid CSRF token')
      end

      it 'Cookieのみでヘッダーがない場合403エラーを返すこと' do
        request.cookies['_csrf_token'] = csrf_token

        post :create

        expect(response).to have_http_status(:forbidden)
      end

      it 'ヘッダーのみでCookieがない場合403エラーを返すこと' do
        request.headers['X-CSRF-Token'] = csrf_token

        post :create

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'PUT リクエストの場合' do
      it '有効なCSRFトークンでアクセス成功すること' do
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = csrf_token

        put :update

        expect(response).to have_http_status(:ok)
      end

      it '無効なCSRFトークンで403エラーを返すこと' do
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = 'invalid_token'

        put :update

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'DELETE リクエストの場合' do
      it '有効なCSRFトークンでアクセス成功すること' do
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = csrf_token

        delete :destroy

        expect(response).to have_http_status(:ok)
      end

      it '無効なCSRFトークンで403エラーを返すこと' do
        request.cookies['_csrf_token'] = csrf_token
        request.headers['X-CSRF-Token'] = 'invalid_token'

        delete :destroy

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'GET リクエストの場合' do
      it 'CSRFトークン無しでもアクセス成功すること（基本的にスキップ）' do
        get :show

        expect(response).to have_http_status(:ok)
      end

      context 'logout系のGETアクションの場合' do
        before do
          # custom_logoutアクションをlogoutとして認識させる
          allow(controller).to receive(:params).and_return(action: 'logout')
        end

        it '有効なCSRFトークンでアクセス成功すること' do
          request.cookies['_csrf_token'] = csrf_token
          request.headers['X-CSRF-Token'] = csrf_token

          get :custom_logout

          expect(response).to have_http_status(:ok)
        end

        it '無効なCSRFトークンで403エラーを返すこと' do
          get :custom_logout

          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'CSRFトークンの設定' do
    let(:csrf_token) { CsrfTokenService.generate }

    before do
      request.cookies['_csrf_token'] = csrf_token
      request.headers['X-CSRF-Token'] = csrf_token
    end

    it 'レスポンスにCSRFトークンCookieが設定されること' do
      post :create

      expect(response.cookies['_csrf_token']).to be_present
      expect(response.cookies['_csrf_token']).to match(/\A[A-Za-z0-9_-]+\z/)
    end

    it 'レスポンスボディにCSRFトークンが含まれること' do
      post :create

      json = JSON.parse(response.body)
      expect(json['csrf_token']).to be_present
      expect(json['csrf_token']).to match(/\A[A-Za-z0-9_-]+\z/)
    end

    it 'Cookie設定が適切なセキュリティオプションを持つこと' do
      post :create

      # Cookie の詳細な属性をテスト（実装に依存）
      set_cookie_header = response.headers['Set-Cookie']
      expect(set_cookie_header).to include('samesite=strict').or include('SameSite=Strict')
      expect(set_cookie_header).to include('httponly').or include('HttpOnly')
    end
  end

  describe 'プライベートメソッド' do
    describe '#csrf_protected_action?' do
      it 'POSTメソッドでtrueを返すこと' do
        allow(controller).to receive(:params).and_return(action: 'create')
        allow(request).to receive(:method).and_return('POST')
        expect(controller.send(:csrf_protected_action?)).to be true
      end

      it 'PUTメソッドでtrueを返すこと' do
        allow(controller).to receive(:params).and_return(action: 'update')
        allow(request).to receive(:method).and_return('PUT')
        expect(controller.send(:csrf_protected_action?)).to be true
      end

      it 'PATCHメソッドでtrueを返すこと' do
        allow(controller).to receive(:params).and_return(action: 'update')
        allow(request).to receive(:method).and_return('PATCH')
        expect(controller.send(:csrf_protected_action?)).to be true
      end

      it 'DELETEメソッドでtrueを返すこと' do
        allow(controller).to receive(:params).and_return(action: 'destroy')
        allow(request).to receive(:method).and_return('DELETE')
        expect(controller.send(:csrf_protected_action?)).to be true
      end

      it 'GETメソッドでfalseを返すこと' do
        allow(controller).to receive(:params).and_return(action: 'show')
        allow(request).to receive(:method).and_return('GET')
        expect(controller.send(:csrf_protected_action?)).to be false
      end

      it 'GET logoutでtrueを返すこと' do
        allow(controller).to receive(:params).and_return(action: 'logout')
        allow(request).to receive(:method).and_return('GET')
        expect(controller.send(:csrf_protected_action?)).to be true
      end
    end

    describe '#extract_csrf_token_from_cookie' do
      it 'Cookieからトークンを抽出できること' do
        request.cookies['_csrf_token'] = 'test_token_from_cookie'

        expect(controller.send(:extract_csrf_token_from_cookie)).to eq('test_token_from_cookie')
      end

      it 'Cookieが無い場合nilを返すこと' do
        expect(controller.send(:extract_csrf_token_from_cookie)).to be_nil
      end
    end

    describe '#extract_csrf_token_from_header' do
      it 'ヘッダーからトークンを抽出できること' do
        request.headers['X-CSRF-Token'] = 'test_token_from_header'

        expect(controller.send(:extract_csrf_token_from_header)).to eq('test_token_from_header')
      end

      it 'ヘッダーが無い場合nilを返すこと' do
        expect(controller.send(:extract_csrf_token_from_header)).to be_nil
      end
    end
  end

  describe 'エラーレスポンス形式' do
    it '403エラーのレスポンス形式が適切であること' do
      post :create

      expect(response).to have_http_status(:forbidden)
      expect(response.content_type).to eq('application/json; charset=utf-8')

      json = JSON.parse(response.body)
      expect(json).to have_key('error')
      expect(json['error']).to be_a(String)
    end
  end
end
