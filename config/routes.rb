ActionController::Routing::Routes.draw do |map|

  map.resources :orders

  map.resources :products, :member => { :make_orderable => :post, :remove_orderable => :post, :add_to_cart => :post}

  map.resources :accounts, :member => { :add_member => :post, :remove_member => :get, 
                                        :invoice_by_customer => :get, :invoice_by_product => :get } do |accounts|
    accounts.resources :products, :member => { :make_orderable => :post, :remove_orderable => :post }
  end
  
  map.namespace :admin do |admin|
    admin.resources :categories
    admin.resources :delivery_cycles, :member => { :duplicate => :post } do |delivery_cycles|
      delivery_cycles.resources :orders
    end
    admin.resources :users, :collection => { :compose_users_email => :get, :send_users_email => :get, 
                                             :compose_producers_email => :get, :send_producers_email => :get }, 
                            :member => { :make_admin => :get, :remove_admin => :get }
    admin.resources :reports, :collection => { :invoices_by_customer => :get, :invoices_by_producer => :get }
  end
  
  map.resources :password_resets

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  # The home page for the site admin functions
  map.connect 'admin/', :controller => "admin/home"
  map.resources :producer_account_requests, :controller => 'admin/producer_account_requests', 
                :member => {:approve => :get, :deny => :get }
  
  map.resources :users, :member => {:request_producer_account => :get, 
                                    :remove_from_cart => :get, 
                                    :remove_all_from_cart => :get, 
                                    :category_request => :get, :send_category_request => :post, 
                                    :ordering_request => :get, :send_ordering_request => :post } do |users|
    users.resources :orders, :member => { :terms => :get, :finalize => :get, :invoice => :get }
  end
  
  map.resource :user_session
  map.root :controller => "home", :action => "index" # optional, this just sets the root route
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.comatose_admin 
  map.comatose_root ''
end
