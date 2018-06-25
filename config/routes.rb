# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users,
             defaults: { format: :json },
             only: :registrations,
             controllers: {
               registrations: 'users/registrations'
             }

  get '/oauth/callback', action: :callback, controller: 'oauth/callback'
  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      curated_models = %i[allergy_intolerances care_plans conditions
                        devices documents encounters goals immunizations
                        medication_administrations medication_requests medication_statements
                        observations practitioners procedures]

      resources :profiles do
        resources :providers, controller: :profile_providers, only: %i[index create destroy], as: :providers

        # curated models as raw API
        curated_models.each do |cm|
          resources cm, controller: cm, only: %i[index show], defaults: { raw_models: true }
        end
      end
      resources :providers, only: %i[index show]

      # curated models as FHIR
      curated_models.each do |cm|
        resources cm.to_s.classify.to_sym, controller: cm, only: %i[index show]
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
