Rails.application.routes.draw do
  use_doorkeeper

    devise_for :users,
    defaults: { format: :json },
    only: :registrations,
    controllers: {
      registrations: 'users/registrations'
    }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
