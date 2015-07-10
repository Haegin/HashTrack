#\ -p 4567

require "./hashtrack"

use Rack::Cache, verbose: false

map HashTrack.assets_prefix do
  run HashTrack.sprockets
end

map '/' do
  run HashTrack
end
