require 'sinatra/base'

module Sinatra
  module OauthRoutes
    def self.registered(app)

      def client
        OAuth2::Client.new(
          settings.application_id, '75678e2d7c679885e0c3595d611e1eed393d70cf664b44e56d25f7c3f6cd7178'
          settings.secret, '8d07fb1215a209f4a8c8dbf38e5a810ee0745dc048ef0e75f3404356abd27150'
          :site => settings.site_url,
          :token_method => :post,
        )
      end

      def access_token
        OAuth2::AccessToken.new(client, session[:access_token], :refresh_token => session[:refresh_token])
      end

      def signed_in?
        !session[:access_token].nil?
      end

      app.get '/authorise' do
        redirect client.auth_code.authorize_url(:redirect_uri => settings.redirect_uri)
      end

      app.get '/callback' do
        if params["error"]
          @errors = Hash.new[params["error"]]= params["error_description"]
          erb :error, :layout => :main
        else
          new_token = client.auth_code.get_token(params[:code], :redirect_uri => settings.redirect_uri)
          session[:access_token]  = new_token.token
          session[:refresh_token] = new_token.refresh_token

          redirect '/'
        end
      end
    end
  end

  register OauthRoutes
end
