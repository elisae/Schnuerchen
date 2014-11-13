class App < Sinatra::Base
	
	set :public_folder => "public", :static => true

# - GET pages -----------------------------------------------
  
	get "/" do
		erb :index
	end

	get "/signup" do
		erb :signup
	end

	get "/games" do
		erb :games
	end

	get "/userinsert" do
		erb :userinsert
	end


# - GET data ------------------------------------------------
  
	get '/users' do
		content_type :json
		User.to_json
	end


# - POST data -----------------------------------------------

	post "/user" do
		User.create do |u|
			u.username = params[:username]
			u.age = params[:age]
		end
		erb :userinserted
	end
end
