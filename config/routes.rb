require 'sidekiq/web'
Tracker::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  # devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :devices do
    member do
      get :show_map
    end
    resources :logs do
      collection do
        delete :clear
      end
    end
    resources :fences do
      member do
        post :enable
      end
    end
  end

  resources :logs do
    collection do
      post :device_create
      post :device_create_bs
      post :device_create_gps
      get :device_create_gps
      get :list_special_logs
      get :new_special_log
      post :create_special_log
    end
    member do
      get :bs_detail
      delete :delete_special_log
    end
  end

  resources :change_logs
  resources :feedbacks


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'
  # devise_scope :user do
  #   root to: "devise/sessions#new"
  # end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
