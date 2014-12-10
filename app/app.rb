class App < Sinatra::Base

# - Settings ------------------------------------------------
	
	set :public_folder => "public", :static => true
	set :game_dir, "/javascripts/games/"

	enable :sessions


# - GET pages -----------------------------------------------


	get "/" do
		redirect "/index.html"
	end

	get "/signup" do
		redirect "/signup.html"
	end

	get "/profile" do
	erb :profile
	end

	get "/games" do
		@gamecategories = getGameCategories()
		erb :games
	end

	get "/users/:u_id/profile" do
		puts session[:u_id]
		puts params[:u_id]
		if "#{session[:u_id]}" == params[:u_id]
			puts params[:u_id]
			@user = User.find(:id=>params[:u_id]).to_hash
			puts @user
			erb :profile
		else
			"Not logged in"
		end
	end

	get "/logout" do
		session[:u_id] = nil
		redirect "/logout.html"
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
		@game = Game.first(:operator=>"#{params[:operator]}", 
							:gamerange=>"#{params[:range]}", 
							:gametype=>"#{params[:type]}").to_hash
		puts @game
		puts @game[:filename]
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

	post "/login" do
		@user = User.find(:username => params[:name])
		if (@user && (@user[:password] == params[:password]))
			session[:u_id] = @user[:id]
			redirect "/users/#{@user[:id]}/profile"
		else
			"Login failed"
		end
	end

	post "/games" do
		DB[:games].insert(:name=>params[:name], :filename=>params[:filename], :cssfilename=>params[:cssfilename], :operator=>params[:operator], :range=>params[:range], :type=>params[:type], :scoretype=>params[:scoretype])
		"Game inserted"
	end

	post "/user" do
		User.create do |u|
			u.username = params[:username]
			u.age = params[:age]
		end
		erb :userinserted
  	end

end
