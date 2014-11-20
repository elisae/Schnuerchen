Sequel::Model.plugin :json_serializer

# - INIT -----------------------------------------

DB.drop_table?(:user_trophies, :gamecats, :gamecategories, :trophies, :scores, :games, :scoretypes, :users)


# - USERS ----------------------------------------
unless DB.table_exists?(:users) 
	DB.create_table :users do
		primary_key	:id
		String		:username
		String		:firstname
		String		:email
		String 		:password
	end
end

class User < Sequel::Model(:users)
	many_to_many :trophies
	many_to_many :users
end


# - GAMES ----------------------------------
unless DB.table_exists?(:scoretypes)
	DB.create_table :scoretypes do
		Integer 	:id, :primary_key=>true
		String 		:descr
	end
end

class Scoretype < Sequel::Model(:scoretypes)
end


unless DB.table_exists?(:games)
	DB.create_table(:games) do
		primary_key	:id
		String 		:name
		String		:filename 
		Integer 	:op_id
		Integer 	:rng_id
		Integer 	:cat_id
		foreign_key :st_id, :scoretypes
		unique([:op_id, :rng_id, :cat_id])
	end
end

class Game < Sequel::Model(:games)
end


unless DB.table_exists?(:scores)
	DB.create_table(:scores) do
		primary_key :id
		foreign_key :u_id, :users
		foreign_key :g_id, :games
		DateTime 	:timestamp
		Integer 	:score
	end
end

class Score < Sequel::Model(:scores)
end


unless DB.table_exists?(:trophies)
	DB.create_table(:trophies) do
		primary_key :id
		foreign_key :g_id, :games
		Integer 	:min_score
		Integer 	:pod
		check(:pod=>[1, 2, 3])
	end
end

class Trophy < Sequel::Model(:trophies)
	many_to_many :users
end


DB[:scoretypes].insert([1, "points"])
DB[:scoretypes].insert([2, "seconds"])

DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :op_id=>1, :rng_id=>1, :cat_id=>1, :st_id=>1)









