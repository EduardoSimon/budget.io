Rails.application.routes.draw do
  root 'budgets#index'
  resources :budgets do
    resources :categories
  end

  resources :accounts do
    post "sync", to: "accounts#sync"

    resources :movements
    resources :auth_sessions, only: [:create] do
      get "result", to: "auth_sessions#result"
    end
  end
end
