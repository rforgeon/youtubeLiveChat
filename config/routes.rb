Rails.application.routes.draw do

  root 'welcome#index'

  devise_for :users

  resources :youtube_handlers do
    get :led
  end

  scope '/script', :controller => :youtube_handlers do
        post :led
        post :pingLed
      end


end
