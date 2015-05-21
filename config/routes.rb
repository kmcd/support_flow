Rails.application.routes.draw do
  namespace :activity do
    get :agents, to:'/agents#activity'
    get :customers, to:'/customers#activity'
  end
  
  resources :agents,    only: %i[ index edit update ]
  resources :customers, only: %i[ index edit update ]
  resources :guides
  
  # TODO: refactor auth
  resources :logins, only: %i[ new create show destroy ]
  get '/login', to:'logins#new'
  get '/logout', to:'logins#destroy', defaults:{ id:1 }, as:'logout'
  
  resources :emails, only: %i[ index create ]
  
  resources :requests, only: %i[ index show update ] do
    resource :merge, only: %i[ new create destroy ]
  end
  
  namespace :settings do
    resource  :billing, only: %i[ show update ]
    resources :mailboxes, only: %i[ index ]
  end
  
  resources :signups, only: %i[ new create ]
  get '/signup', to:'signups#new'
  
  resources :teams, only:[] do
    resources :files, only: %i[ create index ]
    resources :images, only: %i[ create index ]
    resources :guides, only: %i[ show ]
    resources :links, only: %i[ index ]
  end
  
  get '/:team(/*guide)', to:'guides#public', as:'public_guide'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
