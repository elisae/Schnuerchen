class App < Sinatra::Base

# - Settings ------------------------------------------------
	
	set :public_folder => "public", :static => true
	set :game_dir, "/javascripts/games/"

	enable :sessions


# - General -----------------------------------------------


	get "/" do
		redirect "/index.html"
	end

	get "/signup" do
		redirect "/signup.html"
	end

	post "/login" do
		@user = User.find(:username => params[:name])
		if (@user && (@user[:password] == params[:password]))
			session[:u_id] = @user[:id]
			redirect "/games"
		else
			"Login failed"
		end
	end

	get "/games" do
		if login?
	    	@user = User.find(:id=>session[:u_id]).to_hash
			@gamecategories = getGameCategories()
			erb :games
		else
			"Not logged in"
		end
	end

	get "/users/:u_id/profil" do
		if login?
			if "#{session[:u_id]}" == params[:u_id]
				@user = User.find(:id=>params[:u_id]).to_hash
        		@friendinfo = getFriendsInfo
				@trophies = getUserTrophies(session[:u_id])
				@gamecategories = getGameCategories()
				erb :profil
			end
		else
			"Not logged in"
		end
	end

	get "/logout" do
		session[:u_id] = nil
		redirect "/logout.html"
	end

	get "/insert" do
		erb :upload
	end

	get "/games/:operator/:range/:type" do
		if login?
			@user = User.find(:id=>session[:u_id]).to_hash
			@game = Game.first(:operator=>"#{params[:operator]}", 
								:gamerange=>"#{params[:range]}", 
								:gametype=>"#{params[:type]}").to_hash
			erb :game
		else
			"Not logged in"
		end
	end


# - GET data ------------------------------------------------
  
	get '/api/users' do
		content_type :json
		User.to_json
  	end

  	get "/games/categories" do
		content_type :json
		JSON.pretty_generate(getGameCategories())
	end

	get "/users/:u_id/trophies" do
		content_type :json
		JSON.pretty_generate(getUserTrophies(params[:u_id]))
	end

	get "/trophies" do
		redirect "/users/#{session[:u_id]}/trophies"
  end

  get "/search/:query" do
    require 'json'
    query = params[:query]
    responseArr = Array.new
    content_type :json
    response = User.where(Sequel.like(:username, query + '%')).select(:username).map{ |user|
      user.to_hash
      responseArr.push(user)
    }
    responseArr.to_json
  end

# - POST data -----------------------------------------------

	post "/score" do
		puts ""
		puts "Score #{params[:score]} for game_id #{params[:g_id]} posted"
		saveScore(session[:u_id], params[:g_id], Integer(params[:score]))
		print ""
	end

	post "/games" do
		DB[:games].insert(:name=>params[:name], :filename=>params[:filename], :cssfilename=>params[:cssfilename], :operator=>params[:operator], :range=>params[:range], :type=>params[:type], :scoretype=>params[:scoretype])
		puts "Game inserted"
	end

	post "/api/user" do
		params.each { |p|
			puts p
		}
		User.create(:username=>params[:username], 
					:firstname=>params[:firstname], 
					:email=>params[:email], 
					:password=>params[:password])
		puts "user angelegt"
  end



end
