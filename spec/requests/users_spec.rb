require 'rails_helper'

RSpec.describe '/users', type: :request do
  let(:valid_attributes) {
    { first_name: 'John', last_name: 'Doe', email: 'john@doe.com', phone: '1234567890' }
  }
  let(:user) { create(:user) }

  describe 'GET /index' do
    let(:path) { '/api/v1/users' }

    it 'returns http success' do
      get path
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of users' do
      create_list(:user, 5)
      get path
      response_body = JSON.parse(response.body)
      expect(response_body.length).to eq(5)
    end
  end

  describe 'GET /show' do
    let(:path) { "/api/v1/users/#{user.id}" }

    it 'returns http success' do
      get path
      expect(response).to have_http_status(:success)
    end

    it 'return valid content' do
      get path
      response_body = JSON.parse(response.body)
      expect(response_body['first_name']).to eq(user.first_name)
      expect(response_body['last_name']).to eq(user.last_name)
      expect(response_body['email']).to eq(user.email)
      expect(response_body['phone']).to eq(user.phone)
    end

    it 'returns http not found' do
      expect{ get '/api/v1/users/0' }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST /create' do
    let(:path) { '/api/v1/users' }

    context 'with valid parameters' do
      before do
        post path, params: { user: valid_attributes }
      end

      it 'creates a new User' do
        expect(response).to have_http_status(:success)
        expect(User.count).to eq(1)
      end

      it 'returns valid content' do
        response_body = JSON.parse(response.body)
        expect(response_body['first_name']).to eq(valid_attributes[:first_name])
        expect(response_body['last_name']).to eq(valid_attributes[:last_name])
        expect(response_body['email']).to eq(valid_attributes[:email])
        expect(response_body['phone']).to eq(valid_attributes[:phone])
      end
    end

    context 'with invalid parameters' do
      let(:blank_params) { { first_name: '', last_name: '', email: '', phone: '' } }

      it 'returns http unprocessable entity' do
        post path, params: { user: blank_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new User' do
        expect{ post path, params: { user: blank_params } }.to change(User, :count).by(0)
      end

      it 'returns error messages' do
        post path, params: { user: blank_params }
        response_body = JSON.parse(response.body)

        expect(response_body['first_name']).to eq(["can't be blank"])
        expect(response_body['last_name']).to eq(["can't be blank"])
        expect(response_body['email']).to include("can't be blank")
      end

      it 'returns error if email is invalid' do
        post path, params: { user: { email: 'invalid_email' } }
        response_body = JSON.parse(response.body)
        expect(response_body['email']).to include('is invalid')
      end

      it 'does not create user if email is taken' do
        create(:user, email: 'john@doe.com')

        post path, params: { user: valid_attributes}
        response_body = JSON.parse(response.body)

        expect(User.count).to eq(1)
        expect(response_body['email']).to include('has already been taken')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:path) { "/api/v1/users/#{user.id}" }
      let(:new_attributes) {
        { first_name: 'Jane' }
      }

      before do
        patch path, params: { user: new_attributes }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the record' do
        user.reload
        expect(user.first_name).to eq(new_attributes[:first_name])
      end
    end

    context 'with invalid parameters' do
      let(:path) { "/api/v1/users/#{user.id}" }
      let(:new_attributes) {
        { first_name: '', last_name: '' }
      }

      before do
        patch path, params: { user: new_attributes }
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the record' do
        user.reload
        expect(user.first_name).to eq(user.first_name)
      end

      it 'returns error messages' do
        response_body = JSON.parse(response.body)
        expect(response_body['first_name']).to eq(["can't be blank"])
        expect(response_body['last_name']).to eq(["can't be blank"])
      end

      it "does not update the record if email is alredy taken" do
        create(:user, email: 'john@doe.com')

        patch path, params: { user: { email: 'john@doe.com' } }
        response_body = JSON.parse(response.body)
        expect(response_body['email']).to include('has already been taken')
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:users) { create_list(:user, 3) }
    let!(:courses) { create_list(:course, 3) }

    let!(:user_course1) { create(:course_user, user: users[0], course: courses[0], role: :author) }
    let!(:user_course2) { create(:course_user, user: users[0], course: courses[1], role: :author) }
    let!(:user_course3) { create(:course_user, user: users[1], course: courses[2], role: :author) }

    it "destroys the requested user" do
      delete "/api/v1/users/#{users[0].id}"
      expect(response).to have_http_status(:success)

      expect(User.count).to eq(2)
    end

    it "transffers courses of author to other author" do
      delete "/api/v1/users/#{users[0].id}"
      expect(User.count).to eq(2)
      user_course1.reload
      user_course2.reload
      expect(user_course1.user).to eq(users[1])
      expect(user_course2.user).to eq(users[1])
    end
  end
end
