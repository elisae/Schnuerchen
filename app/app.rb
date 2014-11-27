class App < Sinatra::Base

# - Settings ------------------------------------------------
	
	set :public_folder => "public", :static => true
	set :game_dir, "/javascripts/games/"

# - Functions -----------------------------------------------

	def getGameCategories
		gametypes_hash = Gametype.map { |gt|
			gt.to_hash
		}
		ranges_hash = Gamerange.map { |rng|
			rng.to_hash.merge({:gametypes => gametypes_hash})
		}
		operators_hash = Operator.map { |op|
			op.to_hash.merge({:ranges => ranges_hash})
		}
		return operators_hash
	end


# - GET pages -----------------------------------------------
  
	get "/" do
		"Hello World"
	end

	get "/signup" do
		erb :signup
	end

	get "/games" do
		@gamecategories = getGameCategories()
		erb :games
	end

	get "/games/categories" do
		content_type :json
		JSON.pretty_generate(getGameCategories())
	end

	get "/insert" do
		erb :upload
	end

	get "/games/:operator/:range/:type" do
		@game = Game[:operator=>"#{params[:operator]}", :range=>params[:range], :type=>"#{params[:type]}"].to_hash
		erb :game
	end

	get "/games/dummy" do
		@title = "Dummy Game"
		@game_path = "dummy_game.js"
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

	post "/games" do
		DB[:games].insert(:name=>params[:name], :filename=>params[:filename], :cssfilename=>params[:cssfilename], :operator=>params[:operator], :range=>params[:range], :type=>params[:type], :scoretype=>params[:scoretype])
		"Game inserted"
	end

	post "/api/user" do
		User.create do |u|
			u.username = params[:username]
			u.age = params[:age]
		end
		erb :userinserted
	end

end
