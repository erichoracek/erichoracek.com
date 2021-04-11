require 'sinatra'
require 'github_api'
require 'dalli'
require 'sass'
require 'haml'
require 'memcachier'
require 'newrelic_rpm'
require 'rack-google-analytics'
require './repos'

configure do
  # Logfile
  Dir.mkdir('log') unless File.exist?('log')
  log = File.new("log/sinatra.log", "a")
  STDOUT.reopen(log)

  # Google Analytics
  use Rack::GoogleAnalytics, :tracker => 'UA-15242931-2'

  # Memcache
  set :cache, Dalli::Client.new

  # Github Repos
  Repos.set_repo_names [
    'msdynamicsdrawerviewcontroller',
    'mscollectionviewcalendarlayout',
    'motif'
  ]

  Repos.update

end

# Stlyesheets
get '/application.css' do
  content_type 'text/css; charset=utf-8'
  sass :'stylesheets/application'
end

get '/' do
  haml :home, layout: :layout
end
