Sequel::Model.plugin :json_serializer

# - INIT -----------------------------------------

DB.drop_table?(:user_trophies, :gamecats, :gamecategories, :trophies, :scores, :games, :scoretypes, :gametypes, :ranges, :operators, :users)


# - USERS ----------------------------------------
unless DB.table_exists?(:users) 
	DB.create_table(:users) do
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

unless DB.table_exists?(:operators)
	DB.create_table(:operators) do
		String 		:name, :primary_key=>true
	end
end
DB[:operators].insert("addi")
DB[:operators].insert("subt")
DB[:operators].insert("mult")
DB[:operators].insert("divi")
DB[:operators].insert("mix")


unless DB.table_exists?(:scoretypes)
	DB.create_table(:scoretypes) do
		String 		:name, :primary_key=>true
	end
end
DB[:scoretypes].insert("points")
DB[:scoretypes].insert("seconds")


unless DB.table_exists?(:ranges)
	DB.create_table(:ranges) do
		String 		:name, :primary_key=>true
	end
end
DB[:ranges].insert("10")
DB[:ranges].insert("100")
DB[:ranges].insert("20")
DB[:ranges].insert("small")
DB[:ranges].insert("big")
DB[:ranges].insert("all")


unless DB.table_exists?(:gametypes)
	DB.create_table(:gametypes) do
		String 		:name, :primary_key=>true
	end
end
DB[:gametypes].insert("scale")
DB[:gametypes].insert("time")
DB[:gametypes].insert("score")


unless DB.table_exists?(:games)
	DB.create_table(:games) do
		primary_key	:id
		String 		:name
		String		:filename 
		String	 	:cssfilename
		String		:operator
		String		:range
		String 		:type
		String 		:scoretype
		foreign_key [:operator], :operators
		foreign_key [:range], :ranges
		foreign_key [:type], :gametypes
		foreign_key [:scoretype], :scoretypes
		unique([:operator, :range, :type])
	end
end

class Game < Sequel::Model(:games)
end

DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"addi", :range=>"10", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"addi", :range=>"20", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"addi", :range=>"20", :type=>"scale", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"addi", :range=>"100", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"addi", :range=>"100", :type=>"scale", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"subt", :range=>"10", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"subt", :range=>"10", :type=>"time", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"subt", :range=>"10", :type=>"scale", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"mult", :range=>"small", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"mult", :range=>"big", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"divi", :range=>"10", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"divi", :range=>"10", :type=>"time", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"mix", :range=>"10", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"mix", :range=>"100", :type=>"score", scoretype: "points")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>"mix", :range=>"20", :type=>"score", scoretype: "points")


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







