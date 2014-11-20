class App < Sinatra::Base
	
	set :public_folder => "public", :static => true

	set :game_dir, "../javascripts/games/"

# - GET pages -----------------------------------------------
  
	get "/" do
		"Hello World"
	end

	get "/signup" do
		erb :signup
	end

	get "/games" do
		erb :games
	end

	get "/game/dummy" do
		@title = "Dummy Game"
		@game_path = "#{settings.game_dir}" + "dummy_game.js"
		erb :game
	end

	get "/userinsert" do
		erb :userinsert
	end


# - GET data ------------------------------------------------
  
	get '/api/users' do
		content_type :json
		User.to_json
	end


# - POST data -----------------------------------------------

	post "/api/user" do
		User.create do |u|
			u.username = params[:username]
			u.age = params[:age]
		end
		erb :userinserted
	end
end
