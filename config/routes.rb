Rails.application.routes.draw do
  namespace :api, defaults: { format: :json} do
    namespace :v1 do
      resources :courses do
        post 'enroll', to: 'courses#enroll'
        delete 'unenroll', to: 'courses#unenroll'
      end
      resources :users
    end
  end
end
