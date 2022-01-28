module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

    # GET /users
      def index
        @users = User.all

        render json: @users
      end

    # GET /users/1
      def show
        render json: @user
      end

    # POST /users
      def create
        @user = User.new(user_params)

        if @user.save
          render json: @user, status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

    # PATCH/PUT /users/1
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

    # DELETE /users/1
      def destroy
        user_courses = @user.courses

        if user_courses.empty?
          @user.delete_enrollments

          @user.destroy
        else
          ActiveRecord::Base.transaction do
            # lets courses transfer to next user (we can pass id of next user)
            other_user = User.where.not(id: @user.id).first

            user_courses.each do |course|
              course.author = other_user
              course.save
            end

            @user.delete_enrollments
            @user.destroy
          end
        end
      end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :phone)
      end
    end
  end
end
