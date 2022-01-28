require 'rails_helper'

RSpec.describe '/courses', type: :request do
  let(:valid_attributes) { { author_id: user.id,  title: 'Ruby on Rails', description: 'Learn Ruby on Rails' } }
  let!(:user) { create(:user) }
  let(:course) { create(:course) }

  describe 'GET /index' do
    let(:path) { '/api/v1/courses'}
    let!(:courses) { create_list(:course, 5) }

    it 'returns http success' do
      get path
      expect(response).to have_http_status(:success)
    end

    it 'return valid content' do
      get path
      response_body = JSON.parse(response.body)
      expect(response_body.length).to eq(5)
    end
  end

  describe 'GET /show' do
    let(:path) { "/api/v1/courses/#{course.id}" }

    it 'returns http success' do
      get path
      expect(response).to have_http_status(:success)
    end

    it 'return valid content' do
      get path
      response_body = JSON.parse(response.body)
      expect(response_body['title']).to eq(course.title)
      expect(response_body['description']).to eq(course.description)
    end

    it 'returns http not found' do
      expect{get '/api/v1/courses/0'}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      let(:path) { '/api/v1/courses' }

      before do
        post path, params: { course: valid_attributes }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates a new course' do
        expect(Course.count).to eq(1)
      end

      it 'returns new course content' do
        response_body = JSON.parse(response.body)
        expect(response_body['title']).to eq(valid_attributes[:title])
        expect(response_body['description']).to eq(valid_attributes[:description])
      end
    end

    context 'with invalid parameters' do
      let(:path) { '/api/v1/courses' }

      it 'returns http unprocessable entity' do
        post path, params: { course: { author_id: user.id, title: '', description: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create new record' do
        post path, params: { course: { author_id: user.id, title: '', description: '' } }
        expect(Course.count).to eq(0)
      end

      it 'returns error if author is not present' do
        post path, params: { course: { title: 'Ruby on Rails', description: 'Learn Ruby on Rails' } }
        response_body = JSON.parse(response.body)
        expect(response_body['author']).to eq(['not found'])
      end

      it 'returns error message' do
        post path, params: { course: { author_id: user.id, title: '', description: '' } }
        response_body = JSON.parse(response.body)

        expect(response_body['title']).to eq(["can't be blank"])
        expect(response_body['description']).to eq(["can't be blank"])
      end

      it 'does not create new record if title is already taken' do
        another_course = create(:course, title: 'Ruby on Rails', description: 'Learn Ruby on Rails')

        post path, params: { course: { author_id: user.id, title: 'Ruby on Rails', description: 'Learn Ruby on Rails' } }
        expect(Course.count).to eq(1)

        response_body = JSON.parse(response.body)
        expect(response_body['title']).to eq(['has already been taken'])
      end
    end
  end


  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:path) { "/api/v1/courses/#{course.id}" }
      let(:new_attributes) {
        { title: 'Ruby on Rails V1', description: 'Learn Ruby on Rails' }
      }

      before do
        patch path, params: { course: new_attributes }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the record' do
        course.reload
        expect(course.title).to eq('Ruby on Rails V1')
        expect(course.description).to eq('Learn Ruby on Rails')
      end
    end

    context 'with invalid parameters' do
      let(:path) { "/api/v1/courses/#{course.id}" }
      let(:new_attributes) {
        { title: '', description: '' }
      }

      before do
        patch path, params: { course: new_attributes }
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the record' do
        course.reload
        expect(course.title).not_to eq('')
        expect(course.description).not_to eq('')
      end

      it 'returns error message' do
        response_body = JSON.parse(response.body)
        expect(response_body['title']).to eq(["can't be blank"])
        expect(response_body['description']).to eq(["can't be blank"])
      end

      it 'do not update the record if title is already taken' do
        other_course = create(:course)

        patch path, params: { course: { title: other_course.title } }
        expect(Course.count).to eq(2)

        response_body = JSON.parse(response.body)
        expect(response_body['title']).to eq(['has already been taken'])
      end
    end
  end

  describe 'POST /enroll' do
    let(:path) { "/api/v1/courses/#{course.id}/enroll" }

    context 'with valid parameters' do
      it 'returns http success' do
        post path, params: { talent_id: user.id }
        expect(response).to have_http_status(:success)
      end

      it 'enrolls the user' do
        post path, params: { talent_id: user.id }
        course.reload
        expect(course.talents).to include(user)
      end

      it 'should not allow same user to enroll again' do
        create(:course_user, course: course, user: user, role: :talent)

        post path, params: { talent_id: user.id }
        response_body = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid parameters' do
      it 'returns http unprocessable entity' do
        post path, params: { talent_id: '' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not enroll the user' do
        post path, params: { talent_id: '' }
        course.reload
        expect(course.talents.count).to eq(0)
      end

      it 'returns error message' do
        post path, params: { talent_id: '' }
        response_body = JSON.parse(response.body)
        expect(response_body['talent']).to eq(['not found'])
      end
    end
  end

  describe 'DELETE /unenroll' do
    let(:path) { "/api/v1/courses/#{course.id}/unenroll" }

    before do
      create(:course_user, course: course, user: user, role: :talent)
    end

    context 'with valid parameters' do
      it 'returns http success' do
        delete path, params: { talent_id: user.id }
        expect(response).to have_http_status(:success)
      end

      it 'unenrolls the user' do
        delete path, params: { talent_id: user.id }
        course.reload
        expect(course.talents).not_to include(user)
      end
    end

    context 'with invalid parameters' do
      it 'returns http unprocessable entity' do
        delete path, params: { talent_id: '' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not enroll the user' do
        delete path, params: { talent_id: '' }
        course.reload
        expect(course.talents.count).to eq(1)
      end

      it 'returns error message' do
        delete path, params: { talent_id: '' }
        response_body = JSON.parse(response.body)
        expect(response_body['talent']).to eq(['not found'])
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested course' do
      other_course = create(:course)
      expect {
        delete "/api/v1/courses/#{other_course.id}"
      }.to change(Course, :count).by(-1)
    end
  end
end
