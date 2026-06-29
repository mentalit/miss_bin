# config/routes.rb — replace your stores block with this:

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "stores#index"

  shallow do
    resources :stores do
      get  :all_aisles
      get  :aisle
      resources :articles do
        collection { post :import }
      end
      resources :scans, only: [:index] do
        collection do
          post :start
          get  :scan
          post :capture
          get  :skip
          get  :results
        end
      end
    end
  end
end