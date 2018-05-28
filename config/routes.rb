Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  api_routes = lambda do
    get 'providers', to: 'providers#index'

    match '*path', to: redirect('/not_found'), via: :all
  end

  scope '' do
    match 'not_found', to: 'application#not_found', via: :all
    namespace :v1, &api_routes
    scope module: :v1, &api_routes

    # needs wildcard path in default version or it will cause infinite loop of redirects
    match '/*path', to: redirect('/v1/%{path}'), via: [:get, :patch, :post, :put, :delete]
  end
end
