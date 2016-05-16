Rails.application.routes.draw do

  root 'home#index'

  devise_for :users, :skip => [:sessions], controllers: { registrations: 'registrations' }
  devise_scope :user do
    get     'login'    => 'devise/sessions#new',      as: :new_user_session
    post    'login'    => 'devise/sessions#create',   as: :user_session
    delete  'logout'   => 'devise/sessions#destroy',  as: :destroy_user_session
    get     'settings' => 'registrations#edit',       as: :edit_settings
  end

  # Add user profile page & dashboard
  scope 'dashboard' do
    get ''               => 'users#show_dashboard',                as: :dashboard
    get 'visualizations' => 'users#show_dashboard_visualizations', as: :visualizations_dashboard
    get 'stories'        => 'users#show_dashboard_stories',        as: :stories_dashboard
  end
  resources :users, :only => [:show] do
    collection do
      get ':id/visualizations' => 'users#show_visualizations', as: :visualizations
      get ':id/stories'        => 'users#show_stories',        as: :stories
    end
  end

  resources :visualizations, :only => [:show, :edit, :new, :create, :update, :destroy] do
    collection do
      get  ':id/edit/info' => 'visualizations#editinfo'
      post 'publish'
      post 'unpublish'
    end
  end

  resources :stories, :only => [:show, :edit, :new, :create, :update, :destroy] do
    collection do
      get  ':id/edit/info'    => 'stories#editinfo'
      get  ':id/edit/chapter' => 'stories#editchapter'
      post 'publish'
      post 'unpublish'
    end
  end

  resources :datasets, :only => [:index]

  resources :nodes, :only => [:index, :edit, :update] do
    collection do
      get ':id/edit/description' => 'nodes#edit_description'
      get ':id/edit/image'       => 'nodes#edit_image'
    end
  end

  get '/explore'                 => 'pages#explore_stories'
  get '/explore/visualizations/' => 'pages#explore_visualizations'
  get '/explore/stories/'        => 'pages#explore_stories'
  get '/gallery'                 => 'pages#gallery'


  # API routes
  namespace :api, defaults: { format: :json } do
    resources :visualizations, only: [ :show, :update ] do
      get 'nodes', to: 'nodes#index'
      get 'nodes/types', to: 'nodes#types'
      get 'relations', to: 'relations#index'
      get 'relations/types', to: 'relations#types'
    end
    resources :nodes, except: [ :index, :new, :edit ]
    resources :relations, except: [ :index, :new, :edit ]
  end

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
