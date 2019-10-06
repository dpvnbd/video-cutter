Rails.application.routes.draw do
  mount Rswag::Api::Engine => 'api/docs'
  mount Rswag::Ui::Engine => 'api/docs'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :video_uploads, only: [:index, :show, :destroy, :create] do
        post :restart, on: :member
      end
    end
  end
end
