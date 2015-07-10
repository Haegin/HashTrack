# require "sinatra"
# require "instagram"
# require "pry"
# require "tilt/erb"
# require "sass/plugin/rack"

# require "sinatra/reloader" if development?

require "bundler"
Bundler.require(:default, ENV["RACK_ENV"])

$LOAD_PATH.unshift(".")
require "helpers/time_helper"

class HashTrack < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :sprockets, Sprockets::Environment.new(root)
  set :precompile, [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
  set :assets_prefix, "/assets"
  set :digest_assets, false
  set(:assets_path) { File.join public_folder, assets_prefix }

  configure do
    %w{javascripts stylesheets images}.each do |type|
      sprockets.append_path "assets/#{type}"
      sprockets.append_path Compass::Frameworks["bootstrap"].templates_directory + "/../vendor/assets/#{type}"
    end
    sprockets.append_path "assets/fonts"

    # Configure Sprockets::Helpers (if necessary)
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = assets_prefix
      config.digest      = digest_assets
      config.public_path = public_folder
    end
  end

  helpers do
    include Sprockets::Helpers
    include TimeHelper
    # include RenderPartial
  end

  enable :sessions
  enable :logging, :dump_errors, :raise_errors

  CALLBACK_URL = "http://localhost:4567/oauth/callback"

  Instagram.configure do |config|
    config.client_id = "048128b58c1848b999d6200c99aaf4bb"
    config.client_secret = "d88b4a098b5648909c8f62a8da910516"
    # For secured endpoints only
    #config.client_ips = '<Comma separated list of IPs>'
  end

  get "/" do
    '<a href="/oauth/connect">Connect with Instagram</a>'
  end

  get "/oauth/connect" do
    redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
  end

  get "/oauth/callback" do
    response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
    session[:access_token] = response.access_token
    redirect "/tags"
  end

  get "/tags" do
    client = Instagram.client(access_token: session[:access_token])
    search_term = params[:tag] || "trsm"
    results = client.tag_search(search_term)
    erb :tags, locals: {client: client, results: results}
  end

  get "/limits" do
    client = Instagram.client(access_token: session[:access_token])
    html = "<h1/>View API Rate Limit and calls remaining</h1>"
    response = client.utils_raw_response
    html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"

    html
  end
end
