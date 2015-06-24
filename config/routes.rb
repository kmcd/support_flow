Rails.application.routes.draw do
  resources :teams, only: %i[ show ], path:'/', param: :name do
    shallow do
      resources :agents
      resources :customers
      resources :guides
    end
    
    resources :requests, param: :name
    resources :files,     only: %i[ create index ]
    resources :images,    only: %i[ create index ]
    resources :links,     only: %i[ index ]
  end

  # TODO: remove nesting - pass request param instead
  resources :requests, only:[] do
    resource :merge, only: %i[ new create destroy ]
  end

  resources :emails, only: %i[ index create ] # Mandrill webhook endpoint

  namespace :settings do
    with_options(only: %i[]) do |app|
      app.resources :mailboxes
      app.resource  :templates
      app.resource  :notifications
      app.resource  :billing
    end
  end

  # TODO: refactor auth
  resources :logins, only: %i[ new create show destroy ]
  get '/login', to:'logins#new'
  get '/logout', to:'logins#destroy', defaults:{ id:1 }, as:'logout'
  resources :signups, only: %i[ new create ]
  get '/signup', to:'signups#new'
  
  # TODO: validate nested resources
  get '/:team_name/:guide_name', to:'guides#show', as:'public_guide'
end
