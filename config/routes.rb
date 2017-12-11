Starterpad::Application.routes.draw do
  
  ActiveAdmin.routes(self)
  # Devise
  devise_for :users, :controllers => { :registrations => "user/registrations", confirmations: 'user/confirmations', sessions: 'user/sessions' }

  resources :notifications
  resources :conversations, :only => [:index, :create, :show, :update] do
    member do
      get :hide
    end
  end
  resources :private_messages

  # CakePHP Redirections
  get 'group/:id', to: redirect('/groups/%{id}')
  get 'startups/index', to: redirect('/startups')
  get 'startup/:id', to: redirect('/startups/%{id}')  
  get 'startups/index/keywords:(:market_id)', to: redirect { |path_params, req| "/startups/markets/#{path_params[:market_id].to_url}" }, :constraints => { :market_id => /[^\/]+/ }
  get 'starters/skill:(:keyword_id)', to: redirect { |path_params, req| "/starters/skill/#{path_params[:keyword_id].to_url}" }, :constraints => { :keyword_id => /[^\/]+/ }
  get 'starters/role:(:role_id)', to: redirect { |path_params, req| "/starters/role/#{path_params[:role_id].to_url}" }
  get 'users/view/:id/page:page_id', to: redirect { |path_params, req| 
    path_params[:page_id][0] = '' if path_params[:page_id]
    path_params[:page_id] = 'friends' if path_params[:page_id] == 'connections'
    "/#{path_params[:id]}/#{path_params[:page_id]}" 
  }
  get 'pages/display/privacy', to: redirect('/privacy')


  resources :startups, :controller => 'startups' do
    collection do
      get :my_startups
      get :following_startups
      get 'pages/:page' => :index
      get 'markets/:market_id(/:page)' => :by_market, :as => :market
      post 'country'
      get 'country(/:title(/:page))' => "startups#country", :as => :get_by_country
      get 'country_auto_complete'
      post 'city'
      get 'city(/:name(/:page))' =>  "startups#city", :as => :get_by_city
      get 'city_auto_complete'
      get 'autocomplete'
    end
    resources :posts, only: [:create, :destroy, :index], controller: 'startup_posts'
    member do
      post :follow
      post :unfollow
    end
  end
  resources :starters, :controller => 'users', :only => [:index] do
    collection do
      get 'pages/:page' => :index
      get 'role/:role_id(/:page)' => :by_role, :as => :role
      get 'skill/:keyword_id(/:page)' => :by_keyword, :as => :skill
      post 'country'
      get 'country(/:title(/:page))' => "users#country", :as => :get_by_country
      get 'country_auto_complete'
      post 'city'
      get 'city(/:name(/:page))' => "users#city", :as => :get_by_city
      get 'city_auto_complete'
    end
  end
  resources :groups do
    member do
      post 'join/:user_id' => :join, :as => :join
      delete 'leave/:user_id' => :leave, :as => :leave
      post 'suggest_to_friend' => :suggest_to_friend, :as => :suggest_to_friend
    end
    resources :posts, only: [:create, :destroy, :index], controller: 'group_posts'
    collection do
      get 'autocomplete'
      get 'pages/:page' => :index
      get 'my_groups(/pages/:page)' => :my_groups, :as => :my
      get 'my_moderated_groups(/pages/:page)' => :my_moderated_groups, :as => :my_moderated
    end
  end
  resources :posts, :except => [:index] do
    collection do
      get 'pages/:page' => :index
    end
    resources :comments, :only => [:create, :index, :destroy]
    resources :likes, :only => [:index, :create, :destroy]
  end

  resources :users, only: [:update] do
    collection do
      get 'step/:step' => :wizard, :as => :wizard
      put :ping
    end
    resources :friends, :controller => 'user/friendships', :only => [:create, :destroy] do
      member do
        delete :cancel
        put :accept
      end
    end
    collection do
      get :friends, :to => 'user/friendships', :format => :json
    end
    member do
      match :update_settings , :to => 'users#update_settings', :via => [:patch]
    end
    resource :followerships, :controller => 'user/followerships', :only => [:create, :destroy]
  end

  resources :contact, :only => [:index, :create]
  
  authenticated :user do
    get '/', :to => "pages#pad"
  end
  
  devise_scope :user do
    get '/', :to => 'pages#home'
  end

  root :to => 'pages#home'

  # OAuth
  get 'auth/:provider/disconnect', to: 'sessions#disconnect'
  get 'auth/:provider/callback', to: 'sessions#connect'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'facebook_disconnect', to: 'user_facebooks#facebook_disconnect', as: 'facebook_disconnect'
  get 'twitter_disconnect', to: 'user_twitters#twitter_disconnect', as: 'twitter_disconnect'

  # Pages
  get '/badges' => 'pages#badges'
  get '/privacy' => 'pages#privacy'
  get '/terms' => 'pages#terms'

  # Users
  get 'profile', :to => 'users#profile', :as => 'my_profile'
  get 'profile/details',  to: 'users#profile_details', :as => 'my_profile_details'
  get 'profile/change_password',  to: 'users#change_password', :as => 'change_password'
  get 'profile/email_settings',  to: 'users#email_settings', :as => 'email_settings'
  get 'profile/social_network_settings', to: 'users#social_network_settings', as: 'social_network_settings'
  match 'profile/email_addresses', to: 'users#email_addresses', as: :user_email_addresses, via: [:get, :post]
  match 'profile/twitter_update_settings', to: 'users#twitter_update_settings', as: 'twitter_update_settings', via: [:get, :patch]

  get '/user_online_ping',  to: 'users#online_ping', :as => 'user_online_ping'
  get '/sign_action',  to: 'users#sign_action', :as => 'sign_action'
  match 'deactivate_account', to: 'users#deactivate_account', via: [:get, :post], as: 'deactivate_account'  
  match 'resend_confirmation', to: 'users#resend_confirmation', via: [:post], as: 'resend_confirmation'  
  # Conversations
  get '/inbox' => 'conversations#index'

  # Keywords
  resources :keywords, only: [:index]

  # Friends
  get '/contacts' => 'user/friendships#my_friends', :as => "my_friends"

  # Cronjobs
  get '/cronjobs/begin' => 'cronjobs#begin'
  
  # at the moment commenting out this routes, there are no sign of this usage.
  # get '/follow_startup/:id',  to: 'startup_followers#create', :as => "follow_startup"
  get '/startup_followers/:id',  to: 'followers#index', :as => "startup_followers"
   
  get ':url/friends(/page/:page)', :to => 'user/friendships#index', :as =>'friends'
  get ':url/followers(/page/:page)', :to => 'user/followerships#index', :as =>'followers'
  get ':url/followings(/page/:page)', :to => 'user/followerships#followings', :as =>'followings'

  # For Deployment
  # post 'deploy/T5ns7Pqv3G6' => 'deployments#deploy'

  # Test
  match 'test', via: :get, to: lambda {|id| 
    html = 'test'
    [200, {'Content-Type' => 'text/plain'} , [html]] 
  }

  # DISCUSS
  
  resources :items, path: 'discuss', except: [:destroy] do
    
    resources :item_comments

    collection do
      get :newest, to: 'items#newest'
    end
    member do      
      post :toggle
      post :vote, to: 'user_item_votes#create'
      delete :vote, to: 'user_item_votes#destroy'
    end
  end

  # Show User (Always the last one)
  get ':url', :to => 'users#show', :as =>'profile', constraints: ActiveUserConstraint

end
