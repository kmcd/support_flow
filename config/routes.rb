Rails.application.routes.draw do
  constraints({ domain: /\.net$/i }) do
    resources :teams, only: %i[ show ], path:'/', param: :name do
      shallow do
        resources :agents
        resources :customers
        resources :guides
      end

      resources :requests, param: :number
      resources :files,     only: %i[ create index ]
      resources :images,    only: %i[ create index ]
      resources :links,     only: %i[ index ]
    end

    namespace :settings do
      with_options(only: %i[]) do |app|
        app.resources :mailboxes
        app.resource  :templates
        app.resource  :notifications
        app.resource  :billing
      end
    end

    resources :emails, only: %i[ index create ] # Mandrill webhook endpoint

    # TODO: refactor auth to:
    # resource :login
    # resource :signup
    resources :logins, only: %i[ new create show destroy ]
    get '/login', to:'logins#new'
    get '/logout', to:'logins#destroy', defaults:{ id:1 }, as:'logout'
    resources :signups, only: %i[ new create ]
    get '/signup', to:'signups#new'
  end

  constraints({ domain: /\.com$/i }) do
    get '/:team_name/search',
      to:'guides#search',
      as:'guides_search'

    get '/:team_name/(:guide_name)',
      to:'guides#show',
      as:'public_guide',
      defaults: { guide_name:'index' }
  end
end
