class App < Sinatra::Base

# - Settings ------------------------------------------------
	
	set :public_folder => "public", :static => true
	set :game_dir, "/javascripts/games/"

	enable :sessions


# - General -----------------------------------------------
	
	not_found do
		redirect "/404.html"
	end

	get "/" do
    @landing = true
		erb :landing, :layout => :layout_notLoggedIn
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
      redirect "/loginFailed"
    end
  end

  get "/loginFailed" do
    erb :loginFailed,
        :layout => :layout_notLoggedIn
  end

	get "/games" do
		if login?
	    	@user = User.find(:id=>session[:u_id]).to_hash
			@gamecategories = getGameCategories()
			erb :games
		else
			redirect "/loginFailed"
		end
	end

	get "/users/:u_id/profil" do
		if login?
      @user = User.find(:id=>params[:u_id]).to_hash

      if "#{session[:u_id]}" == params[:u_id]
        @friends = getFriendsInfo(session[:u_id])
        @friendReqsOut = getReqsOut(session[:u_id])
        @friendReqsIn = getReqsIn(session[:u_id])
				@trophies = getUserTrophies(session[:u_id])
				@gamecategories = getGameCategories()
				erb :profil
      else
        erb :user
			end
		else
			"Not logged in"
		end
	end

	get "/logout" do
		session[:u_id] = nil
		erb :logout,
        :layout => :layout_notLoggedIn
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
    response = User.where(Sequel.like(:username, query + '%')).select(:id,:username).map{ |user|
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


# TODO automatischer LOGIN
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

	  post "/add/:id" do
      Friendship.create(:friends_with_id => session[:u_id] ,:friend_of_id=> params[:id])
	end

end
