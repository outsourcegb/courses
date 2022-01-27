require 'rails_helper'

RSpec.describe "/courses", type: :request do
  let(:valid_attributes) { { title: "Ruby on Rails", description: "Learn Ruby on Rails" } }
  let(:course) { Course.create! valid_attributes }

  describe "GET /index" do
    let(:path) { '/api/v1/courses'}
    let!(:courses) { create_list(:course, 5) }

    it "returns http success" do
      get path
      expect(response).to have_http_status(:success)
    end

    it "return valid content" do
      get path
      response_body = JSON.parse(response.body)
      expect(response_body.length).to eq(5)
    end
  end

  describe "GET /show" do
    let(:path) { "/api/v1/courses/#{course.id}" }

    it "returns http success" do
      get path
      expect(response).to have_http_status(:success)
    end

    it "return valid content" do
      get path
      response_body = JSON.parse(response.body)
      expect(response_body["title"]).to eq(course.title)
      expect(response_body["description"]).to eq(course.description)
    end

    it "returns http not found" do
      expect{get "/api/v1/courses/0"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:path) { "/api/v1/courses" }

      before do
        post path, params: { course: valid_attributes }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "creates a new course" do
        expect(Course.count).to eq(1)
      end

      it "returns new course content" do
        response_body = JSON.parse(response.body)
        expect(response_body["title"]).to eq(valid_attributes[:title])
        expect(response_body["description"]).to eq(valid_attributes[:description])
      end
    end

    context "with invalid parameters" do
      let(:path) { "/api/v1/courses" }

      before do
        post path, params: { course: { title: "", description: "" } }
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create new record" do
        expect(Course.count).to eq(0)
      end

      it "returns error message" do
        response_body = JSON.parse(response.body)
        expect(response_body["title"]).to eq(["can't be blank"])
        expect(response_body["description"]).to eq(["can't be blank"])
      end

      it "do not create new record if title is already taken" do
        another_course = create(:course, title: "Ruby on Rails", description: "Learn Ruby on Rails")

        post path, params: { course: { title: "Ruby on Rails", description: "Learn Ruby on Rails" } }
        expect(Course.count).to eq(1)

        response_body = JSON.parse(response.body)
        expect(response_body["title"]).to eq(["has already been taken"])
      end
    end
  end


  describe "PATCH /update" do
    context "with valid parameters" do
      let(:path) { "/api/v1/courses/#{course.id}" }
      let(:new_attributes) {
        { title: "Ruby on Rails V1", description: "Learn Ruby on Rails" }
      }

      before do
        patch path, params: { course: new_attributes }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the record" do
        course.reload
        expect(course.title).to eq("Ruby on Rails V1")
        expect(course.description).to eq("Learn Ruby on Rails")
      end
    end

    context "with invalid parameters" do
      let(:path) { "/api/v1/courses/#{course.id}" }
      let(:new_attributes) {
        { title: "", description: "" }
      }

      before do
        patch path, params: { course: new_attributes }
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the record" do
        course.reload
        expect(course.title).to eq("Ruby on Rails")
        expect(course.description).to eq("Learn Ruby on Rails")
      end

      it "returns error message" do
        response_body = JSON.parse(response.body)
        expect(response_body["title"]).to eq(["can't be blank"])
        expect(response_body["description"]).to eq(["can't be blank"])
      end

      it "do not update the record if title is already taken" do
        other_course = create(:course)

        patch path, params: { course: { title: other_course.title } }
        expect(Course.count).to eq(2)

        response_body = JSON.parse(response.body)
        expect(response_body["title"]).to eq(["has already been taken"])
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested course" do
      other_course = create(:course)
      expect {
        delete "/api/v1/courses/#{other_course.id}"
      }.to change(Course, :count).by(-1)
    end
  end
end
