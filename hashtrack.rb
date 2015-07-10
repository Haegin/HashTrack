require "sinatra"
require "instagram"
require "pry"
require "tilt/erb"
require "sass/plugin/rack"

require "sinatra/reloader" if development?

# Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

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
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/tags"
end

get "/tags" do
  client = Instagram.client(:access_token => session[:access_token])
  tags = client.tag_search('trsm')
  erb :tags, locals: {client: client, tags: tags}
end

get "/limits" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1/>View API Rate Limit and calls remaining</h1>"
  response = client.utils_raw_response
  html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"

  html
end
