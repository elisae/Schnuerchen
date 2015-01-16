# encoding: UTF-8
ENV['LANG'] = 'de_DE.UTF-8'
class App < Sinatra::Base

# - Settings ------------------------------------------------
	
	set :public_folder => "public", :static => true
	set :game_dir, "/javascripts/games/"

	enable :sessions


# - General -----------------------------------------------
	
	not_found do
		if login?
			erb :notfound
		else
			erb :notfound, :layout => :layout_notLoggedIn
		end
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
		if @user
			if (@user[:password_hash] == BCrypt::Engine.hash_secret(params[:password], @user[:salt]))
				session[:u_id] = @user[:id]
				redirect "/games"
			end
		else
	      erb :loginFailed, :layout => :layout_notLoggedIn
		end
  	end

  	get "/login" do
  		erb :loginFailed, :layout => :layout_notLoggedIn
  	end

	get "/games" do
		if login?
	    	@user = User.find(:id=>session[:u_id]).to_hash
			@gamecategories = getGameCategories
			erb :games
		else
			erb :loginFailed, :layout => :layout_notLoggedIn
		end
	end

	get "/users/:u_id/profil" do
		if login?
			if @user = User.find(:id=>params[:u_id])
				@user = @user.to_hash
				if "#{session[:u_id]}" == params[:u_id]
					@friends = getFriendsInfo(session[:u_id])
					@friendReqsOut = getReqsOut(session[:u_id])
					@friendReqsIn = getReqsIn(session[:u_id])
					@trophies = getUserTrophies(session[:u_id])
					@gamecategories = getGameCategories
					@friendheader = false
					erb :profil
				else
					@friendheader = true
					@friendStatus = friends?(session[:u_id], Integer(params[:u_id]))
					@friend = User.find(:id=>params[:u_id]).to_hash
					@gamecategories = getGameCategories()
					@trophies = getUserTrophies(params[:u_id])
					erb :user
				end
			else
				erb :notfound
			end
		else
			erb :notloggedin, :layout => :layout_notLoggedIn
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
			erb :notloggedin, :layout => :layout_notLoggedIn
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

  get "/userscores" do
    require 'json'
    content_type :json
    user_id = session[:u_id].to_i
    friend_id = params[:u_id].to_i
    game_id = params[:g_id].to_i
    if user_id == friend_id
      scoresArr = getUserScore(user_id,game_id)
      if !scoresArr.empty?
        return scoresArr.to_json
      else
        status 204
      end
    else
      scoresArr = getFriendScore(user_id,friend_id,game_id)
      return 200
    end

  end

  get "/search" do
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

  get "/test" do
  	redirect "/test.html"
  end

# - POST data -----------------------------------------------

	post "/score" do
		puts ""
		puts "Score #{params[:score]} for game_id #{params[:g_id]} posted"
		saveScore(session[:u_id], params[:g_id], Integer(params[:score])).to_json
	end

	post "/api/user" do
		password_salt = BCrypt::Engine.generate_salt
  		password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)

		if /[^\x00-\x7F]/ =~ params[:username]
			puts "Non-ASCII character found"
			status 420
		elsif User.find(:username=>params[:username])
			puts "user existiert schon"
			status 409 
		else
			params.each { |p|
				puts p
			}
			newUser = User.create(:username=>params[:username], 
						:firstname=>params[:firstname], 
						:email=>params[:email], 
						:salt=>password_salt,
						:password_hash=>password_hash)
			session[:u_id] = newUser.id
			puts "User angelegt und eingeloggt"
			status 200
		end
	  end

	  post "/add/:f_id" do
	  		addFriend(session[:u_id], Integer(params[:f_id]))
	  		status 200
	end

  post "/add" do
    user_id = session[:u_id]
    friend_id = Integer(params[:f_id])
	  addFriend(user_id, friend_id)
	  status 200
  end

  post "/unfriend" do
    user_id = session[:u_id]
    friend_id = params[:f_id].to_i
    delFriend(user_id,friend_id)
    status 200
  end

end
