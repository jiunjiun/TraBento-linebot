Rails.application.routes.draw do
  post :callback, to: 'callback#create', as: :callback
  get 'captcha/:id', to: 'captcha#show', as: :captcha

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
