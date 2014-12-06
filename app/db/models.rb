# ===============================================
#    DB Model Definitions
# ===============================================

Sequel::Model.plugin :json_serializer

# - INIT -----------------------------------------

DB.drop_table?(:user_trophies, :trophies, :scores, :games, :scoretypes, :gameranges_gametypes, :gametypes, :gameranges_operators, :gameranges, :operators, :users)


# - USERS ---------------------------------------
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


# - GAME STRUCTURE ------------------------------

unless DB.table_exists?(:operators)
	DB.create_table(:operators) do
		primary_key	:id
		String 		:name, :unique=>true
		String 		:descr
		String 		:img_filename
	end
end

class Operator < Sequel::Model(:operators)
	plugin :dataset_associations
	one_to_many	:games
	many_to_many :gameranges


	def add_gameranges(*gameranges)
		gameranges.each { |gr|
			self.add_gamerange(gr)
		}
	end
end


unless DB.table_exists?(:gameranges)
	DB.create_table(:gameranges) do
		primary_key	:id
		String 		:name, :unique=>true
		String		:img_filename
	end
end

class Gamerange < Sequel::Model(:gameranges)
	one_to_many	:games
	many_to_many :operators
	many_to_many :gametypes
end



unless DB.table_exists?(:gameranges_operators)
	DB.create_table(:gameranges_operators) do
		primary_key	:id
		foreign_key	:gamerange_id, :gameranges
		foreign_key	:operator_id, :operators
		unique([:gamerange_id, :operator_id])
	end
end



unless DB.table_exists?(:gametypes)
	DB.create_table(:gametypes) do
		primary_key	:id
		String 		:name, :unique=>true
		String		:img_filename
	end
end

class Gametype < Sequel::Model(:gametypes)
	many_to_many :gameranges
end



unless DB.table_exists?(:gameranges_gametypes)
	DB.create_table(:gameranges_gametypes) do
		primary_key	:id
		foreign_key	:gamerange_id, :gameranges
		foreign_key	:gametype_id, :gametypes
		unique([:gamerange_id, :gametype_id])
	end
end



unless DB.table_exists?(:scoretypes)
	DB.create_table(:scoretypes) do
		primary_key	:id
		String 		:name, :unique=>true
	end
end
class Scoretype < Sequel::Model(:scoretypes)
end



# - GAMES ---------------------------------------

unless DB.table_exists?(:games)
	DB.create_table(:games) do
		primary_key	:id
		String 		:name
		String		:filename 
		String	 	:css_filename
		String		:operator
		String		:gamerange
		String	 	:gametype
		String	 	:scoretype
		String		:long_descr
		String 		:img_filename
		unique([:operator, :gamerange, :gametype])
	end
end

class Game < Sequel::Model(:games)

	# Bei Spielerstellung ensprechende Operator, Range, Typ, Scoretype anlegen
	def self.create(values = {}, &block)
		op = Operator.find_or_create(:name => values[:operator])
		gr = Gamerange.find_or_create(:name => values[:gamerange])
		gt = Gametype.find_or_create(:name => values[:gametype])
		unless op.gameranges.include?(gr)
			op.add_gamerange(gr)
		end
		unless gr.gametypes.include?(gt)
			gr.add_gametype(gt)
		end
		Scoretype.find_or_create(:name => values[:scoretype])
		puts "Game erstellt: " + values[:name]
		super
	end
end


# - HIGHSCORES -------------------------------------

unless DB.table_exists?(:scores)
	DB.create_table(:scores) do
		primary_key :id
		foreign_key :user_id, :users
		foreign_key :game_id, :games
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



# ===============================================
#    DB Data Inserts etc.
# ===============================================


# - USERS ----------------------------------------

DB[:users].insert(:id=>1, :username=>"hans231", :firstname=>"Hans", :email=>"h.hans@hans.de", :password=>"hallo")
DB[:users].insert(:id=>2, :username=>"jürgen231", :firstname=>"Jürgen", :email=>"jürgen@jürgen.de", :password=>"hallo")
DB[:users].insert(:id=>3, :username=>"rüdiger231", :firstname=>"Rüdiger", :email=>"rüdiger@rüdiger.de", :password=>"hallo")


Operator.create(:name=>"o_test1").add_gameranges(Gamerange.create(:name=>"g_test1"), Gamerange.create(:name=>"g_test2"))

Operator.create(:name=>"o_test2").add_gameranges(Gamerange.find_or_create(:name=>"g_test1"), Gamerange.create(:name=>"g_test3"), Gamerange.create(:name=>"g_test4"))

Operator.create(:name=>"o_test3").add_gameranges(Gamerange.find_or_create(:name=>"g_test1"), Gamerange.find_or_create(:name=>"g_test4"))


# - GAMES ----------------------------------------

Game.create(:name=>"multiplechoice_dummy", 
			:filename=>"multiplechoice_dummy.js", 
			:operator=>"addi", 
			:gamerange=>"10", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Mult Small", 
			:filename=>"game_n_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"marathon_dummy", 
			:filename=>"marathon_game_dummy_v1.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype=>"marathon", 
			:scoretype=>"seconds", 
			:css_filename=>"dummygamestyle.css")













