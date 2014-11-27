Sequel::Model.plugin :json_serializer

# - INIT -----------------------------------------

DB.drop_table?(:user_trophies, :gamecats, :gamecategories, :trophies, :scores, :games, :scoretypes, :gametypes, :gameranges, :operators, :users)


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
		Integer 	:id, :primary_key=>true
		String 		:shortname, :unique=>true
		String 		:longname
		String 		:img_filename
	end
end
class Operator < Sequel::Model(:operators)
end
DB[:operators].insert(:id=>1, :shortname=>"addi", :longname=>"Addition (Plus)")
DB[:operators].insert(:id=>2, :shortname=>"subt", :longname=>"Subtraktion (Minus)")
DB[:operators].insert(:id=>3, :shortname=>"mult", :longname=>"Multiplikation (Mal)")
DB[:operators].insert(:id=>4, :shortname=>"divi", :longname=>"Division (Geteilt)")
DB[:operators].insert(:id=>5, :shortname=>"mix", :longname=>"Alle gemischt")


unless DB.table_exists?(:scoretypes)
	DB.create_table(:scoretypes) do
		Integer 	:id, :primary_key=>true
		String 		:name, :unique=>true
	end
end
DB[:scoretypes].insert(:id=>1, :name=>"points")
DB[:scoretypes].insert(:id=>2, :name=>"seconds")


unless DB.table_exists?(:gameranges)
	DB.create_table(:gameranges) do
		Integer 	:id, :primary_key=>true
		String 		:name, :unique=>true
		String		:img_filename
	end
end
class Gamerange < Sequel::Model(:gameranges)
end
DB[:gameranges].insert(:id=>1, :name=>"10")
DB[:gameranges].insert(:id=>2, :name=>"100")
DB[:gameranges].insert(:id=>3, :name=>"20")
DB[:gameranges].insert(:id=>4, :name=>"small")
DB[:gameranges].insert(:id=>5, :name=>"big")
DB[:gameranges].insert(:id=>6, :name=>"all")


unless DB.table_exists?(:gametypes)
	DB.create_table(:gametypes) do
		Integer 	:id, :primary_key=>true
		String 		:name, :unique=>true
		String		:img_filename
	end
end
class Gametype < Sequel::Model(:gametypes)
end
DB[:gametypes].insert(:id=>1, :name=>"scale")
DB[:gametypes].insert(:id=>2, :name=>"time")
DB[:gametypes].insert(:id=>3, :name=>"score")


unless DB.table_exists?(:games)
	DB.create_table(:games) do
		primary_key	:id
		String 		:name
		String		:filename 
		String	 	:css_filename
		Integer		:operator
		Integer		:range
		Integer 	:type
		Integer 	:scoretype
		String		:long_descr
		String 		:img_filename
		foreign_key [:operator], :operators
		foreign_key [:range], :gameranges
		foreign_key [:type], :gametypes
		foreign_key [:scoretype], :scoretypes
		unique([:operator, :range, :type])
	end
end
class Game < Sequel::Model(:games)
end

DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>1, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>2, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>2, :type=>3, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>3, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>3, :type=>3, scoretype: 2)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>2, :range=>1, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>2, :range=>1, :type=>2, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>2, :range=>1, :type=>3, scoretype: 2)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>3, :range=>4, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>3, :range=>5, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>4, :range=>1, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>4, :range=>1, :type=>2, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>5, :range=>1, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>5, :range=>3, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>5, :range=>2, :type=>1, scoretype: 1)


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







