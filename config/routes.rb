Rails.application.routes.draw do
  resources :products do
    match '/scrape', to: 'products#scrape', via: :get, on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
