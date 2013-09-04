require 'sidekiq/web'
Teste::Application.routes.draw do
  resources :users
  root :to => 'users#index'

  mount Sidekiq::Web, at: '/sidekiq'
end

#admin = lambda { |request| request.env[:clearance].current_user.try :admin? }
#constraints admin do
#  mount Sidekiq::Web, at: '/admin/sidekiq_web'
#end
