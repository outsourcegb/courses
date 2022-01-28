# frozen_string_literal: true

module Api
  module V1
    class CoursesController < ApplicationController
      before_action :set_course, only: %i[show update destroy]

      # GET /courses
      def index
        @courses = Course.all

        render json: @courses
      end

      # GET /courses/1
      def show
        render json: @course
      end

      # POST /courses
      def create
        author = User.find_by(id: params[:course][:author_id])
        return render json: { author: ['not found'] }, status: :unprocessable_entity unless author

        transaction = ActiveRecord::Base.transaction do
          @course = Course.new(course_params)
          @course.author = author
          @course.save
        end

        if transaction
          render json: @course, status: :created
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /courses/1
      def update
        if @course.update(course_params)
          render json: @course
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end

      # DELETE /courses/1
      def destroy
        @course.destroy
      end

      # post /courses/1/enroll
      def enroll
        user = User.find_by(id: params[:talent_id])
        return render json: { talent: ['not found'] }, status: :unprocessable_entity unless user

        @course = Course.find(params[:course_id])
        talent = CourseUser.new(course: @course, user: user, role: :talent)

        if talent.save
          render json: {}, status: :created
        else
          render json: talent.errors, status: :unprocessable_entity
        end
      end

      # delete /courses/1/unenroll
      def unenroll
        user = User.find_by(id: params[:talent_id])
        return render json: { talent: ['not found'] }, status: :unprocessable_entity unless user

        @course = Course.find(params[:course_id])
        talent = CourseUser.find_by(course: @course, user: user, role: :talent)

        if talent.destroy
          render json: {}, status: :ok
        else
          render json: talent.errors, status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_course
        @course = Course.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def course_params
        params.require(:course).permit(:title, :description)
      end
    end
  end
end
