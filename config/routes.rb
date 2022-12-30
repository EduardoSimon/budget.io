Rails.application.routes.draw do
  resources :budgets
  resources :accounts do
    post "authenticate", to: "accounts#authenticate", action: :authenticate
  end
  resources :movements
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
