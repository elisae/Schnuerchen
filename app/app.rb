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
		redirect "/index.html"
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

	# Bisher geht nur /addi/10/scale
	get "/games/:operator/:range/:type" do
		operator = Operator.where(:shortname=>"#{params[:operator]}").get(:id)
		range = Gamerange.where(:name=>"#{params[:range]}").get(:id)
		type = Gametype.where(:name=>"#{params[:type]}").get(:id)
		puts operator
		puts range
		puts type
		@game = Game.first(:operator=>operator, :range=>range, :type=>type).to_hash
		puts @game
		puts @game[:filename]
		erb :game
	end

	get "/games/dummy" do
		@title = "Dummy Game"
		@game_path = "dummy_game.js"
		erb :game
	end

  get "/game/dummygame" do
    erb :dummygame
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
