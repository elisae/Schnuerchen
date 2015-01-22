# encoding: UTF-8
ENV['LANG'] = 'de_DE.UTF-8'
class App < Sinatra::Base

# - Settings ------------------------------------------------
	
	set :public_folder => "public", :static => true
	set :game_dir, "/javascripts/games/"
	set :game_css_dir, "/stylesheets/game-style"
	set :default_game_css, "dummygamestyle.css"

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
      @gameheader = true
			@user = User.find(:id=>session[:u_id]).to_hash
			@game = Game.first(:operator=>"#{params[:operator]}", 
								:gamerange=>"#{params[:range]}", 
								:gametype_name=>"#{params[:type]}").to_hash
			erb :game
    else
      @gameheader = false
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

	get "/games/find" do
		content_type :json
		search_hash = Hash.new()
		params.each do |k, v|
			search_hash[k.to_sym] = v
		end
		game = Game.where(search_hash).map do |g|
			g.to_hash
		end
		JSON.pretty_generate(game)
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
    game_id = params[:g_id].to_i
    pod = params[:pod].to_i
    scoreArr = Array.new
    scoreArr.push(getUserScore(user_id,game_id))
    scoreArr.push(getMinScore(game_id,pod))
    scoreArr.to_json
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

	get "/games/upload" do
		@operators = Operator.all.map { |op|
			op.to_hash
		}
		@ranges = Gamerange.all.map { |rng|
			rng.to_hash
		}
		@types = Gametype.all.map { |tp|
			tp.to_hash
		}
		erb :gameupload
	end

	post "/games/upload" do
		if params[:js_file]
			puts params[:js_file]
			js_file = params[:js_file][:tempfile]
			js_filename = params[:js_file][:filename]
			if (js_file && !File.exists?("#{settings.game_dir}#{js_filename}"))
				File.open("./public/#{settings.game_dir}#{js_filename}", 'wb') do |f|
					f.write(js_file.read)
				end
			end
		else
			status 409
		end

		if (params[:defaultCSS] == "on")
			css_filename = settings.default_game_css
		else
			if params[:css_file]
				css_file = params[:css_file][:tempfile]
				css_filename = params[:css_file][:filename]
				if (js_file && !File.exists?("#{settings.game_css_dir}#{css_filename}"))
					File.open("#{settings.game_css_dir}#{css_filename}", 'wb') do |f|
						f.write(css_file.read)
					end
				end
			else
				status 409
			end
		end
		newGame = Game.find_or_create(:operator => params[:operator], :gamerange=>params[:gamerange], :gametype_name=>params[:gametype])
		puts "HAAALLOOO"
		puts newGame
		puts "TSCHUUUESS"
		puts params[:scoretype]
		newGame.set(:name => params[:name])
		newGame.set(:filename => js_filename)
		newGame.set(:css_filename => css_filename)
		newGame.set(:scoretype => params[:scoretype])
		newGame.save

		puts params
		status 200
	end

	post "/score" do
		content_type :json
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
