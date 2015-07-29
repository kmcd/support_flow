Rails.application.routes.draw do
  constraints({ domain: /\.net$/i }) do
    resources :teams, only: %i[ show ], path:'/', param: :name do
      shallow do
        resources :agents
        resources :customers
        resources :guides, except: %i[ show ]
      end

      resources :requests, param: :number
      resources :files,     only: %i[ create index ]
      resources :images,    only: %i[ create index ]
      resources :links,     only: %i[ index ]
    end

    namespace :email do
      resources :outbound,    only: %i[ create destroy ]
      resources :attachments, only: %i[ show destroy ]
    end

    namespace :settings do
      resources :mailboxes, only: %i[ index ]
      resources :reply_templates
      resource  :billing, only: %i[ show edit update ]
    end

    resources :logins,  only: %i[ new create show destroy ]
    resources :signups, only: %i[ new create ]
  end

  constraints({ domain: /\.com$/i }) do
    resources :teams, only: %i[], path:'/', param: :name  do
      resource  :search,
        only: %i[ show ],
        controller: :guide_search,
        as: :guide_search

      resources :public_guides,
        path:'/',
        param: :name,
        only: %i[ index show ]
    end
  end

  # TODO: find more elegant solution to localtunnel in development ...
  namespace :email do
    resources :inbound, only: %i[ index create ]
  end
end
