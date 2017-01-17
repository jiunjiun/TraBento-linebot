Rails.application.routes.draw do
  post :callback, to: 'callback#create', as: :callback

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
