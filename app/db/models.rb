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
DB[:users].insert(:id=>1, :username=>"hans231", :firstname=>"Hans", :email=>"h.hans@hans.de", :password=>"hallo")
DB[:users].insert(:id=>2, :username=>"jürgen231", :firstname=>"Jürgen", :email=>"jürgen@jürgen.de", :password=>"hallo")
DB[:users].insert(:id=>3, :username=>"rüdiger231", :firstname=>"Rüdiger", :email=>"rüdiger@rüdiger.de", :password=>"hallo")

# - GAMES ----------------------------------
unless DB.table_exists?(:operators)
	DB.create_table(:operators) do
		Integer 	:id, :primary_key=>true
		String 		:name, :unique=>true
		String 		:descr
		String 		:img_filename
	end
end
class Operator < Sequel::Model(:operators)
	one_to_many	:games
end
DB[:operators].insert(:id=>1, :name=>"addi", :descr=>"Addition (Plus)")
DB[:operators].insert(:id=>2, :name=>"subt", :descr=>"Subtraktion (Minus)")
DB[:operators].insert(:id=>3, :name=>"mult", :descr=>"Multiplikation (Mal)")
DB[:operators].insert(:id=>4, :name=>"divi", :descr=>"Division (Geteilt)")
DB[:operators].insert(:id=>5, :name=>"mix", :descr=>"Alle gemischt")


unless DB.table_exists?(:scoretypes)
	DB.create_table(:scoretypes) do
		Integer 	:id, :primary_key=>true
		String 		:name, :unique=>true
	end
end
class Scoretype < Sequel::Model(:scoretypes)
	one_to_many	:games
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
	one_to_many	:games
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
	one_to_many	:games
end
DB[:gametypes].insert(:id=>1, :name=>"scale")
DB[:gametypes].insert(:id=>2, :name=>"time")
DB[:gametypes].insert(:id=>3, :name=>"score")
DB[:gametypes].insert(:id=>4, :name=>"marathon")


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
	many_to_one	:operators
	many_to_one :gameranges
	many_to_one	:gametypes
	many_to_one	:scoretypes
end

DB[:games].insert(:name=>"multiplechoice_dummy", :filename=>"multiplechoice_dummy.js", :operator=>1, :range=>1, :type=>1, scoretype: 1, css_filename: "dummygamestyle.css")
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>2, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>2, :type=>3, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>3, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>1, :range=>3, :type=>3, scoretype: 2)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>2, :range=>1, :type=>1, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>2, :range=>1, :type=>2, scoretype: 1)
DB[:games].insert(:name=>"Dummy Game", :filename=>"dummy_game.js", :operator=>2, :range=>1, :type=>3, scoretype: 2)
DB[:games].insert(:name=>"Mult Small", :filename=>"game_n_mult_small.js", :operator=>3, :range=>4, :type=>3, scoretype: 1, css_filename: "dummygamestyle.css")
DB[:games].insert(:name=>"marathon_dummy", :filename=>"marathon_game_dummy_v1.js", :operator=>3, :range=>4, :type=>4, scoretype: 2, css_filename: "dummygamestyle.css")
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







