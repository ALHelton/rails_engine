Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      get "/merchants/find", to: "merchant/search#search"
      get "items/find_all", to: "items/search#search"

      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: "merchant_items"
      end
      resources :items, except: [:new] do
        resource :merchant, only: [:show], controller: "item_merchant"
      end
    end
  end
end
