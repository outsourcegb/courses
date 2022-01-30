Rails.application.routes.draw do
  namespace :api, defaults: { format: :json} do
    namespace :v1 do
      resources :courses do
        post 'enroll', to: 'courses#enroll'
        delete 'enroll', to: 'courses#unenroll'
        get 'talents', to: 'courses#talents'
      end
      resources :users do
        get 'enrollments', to: 'users#enrollments'
        get 'courses', to: 'users#courses'
      end
    end
  end
end
