
Rails.application.routes.draw do
    use_doorkeeper
    devise_for :users,
    defaults: { format: :json },
    only: :registrations,
    controllers: {
      registrations: 'users/registrations'
    }
    namespace :api,defaults: { format: :json } do
      namespace :v1 do
        resources :profiles  do
          resources :providers, controller: :profile_providers,  only: [:index, :create, :delete],  as: :providers
        end
        resources :providers, only: [:index,:show]
      end
    end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
