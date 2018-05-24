
Rails.application.routes.draw do
  puts Rake.application.top_level_tasks
  unless rake_task?(%w(db:create db:migrate db:drop db:schema:load))
    use_doorkeeper
    devise_for :users,
    defaults: { format: :json },
    only: :registrations,
    controllers: {
      registrations: 'users/registrations'
    }
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
