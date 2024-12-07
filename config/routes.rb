Rails.application.routes.draw do
  devise_for :users, skip: [:passwords, :confirmations].tap { |skips| skips << :registrations if ENV['DISABLE_REGISTRATIONS'] }

  resources :bookmarks, only: %i[index create update destroy] do
    collection do
      get 'fetch_thumbnail'
    end
  end

  resources :tags, only: [:index, :create, :update, :destroy]

  # Root path
  root 'home#index'
end
