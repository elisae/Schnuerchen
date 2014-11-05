class App < Sinatra::Base

  set :public_folder => "public", :static => true

  get "/" do
    erb :welcome
  end

  get "/users" do
  	"Sample User List"
  end

end

# require_relative 'routes/server'
# require_relative 'routes/client'
require_relative 'db/connect'
require_relative 'models/init'
