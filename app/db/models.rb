# ===============================================
#    DB Model Definitions
# ===============================================

Sequel::Model.plugin :json_serializer


# *************************************************** #
# 												      #
#   Daten einfügen bitte im zweiten Teil (line 192)   #
# 												      #
# *************************************************** #


# - INIT -----------------------------------------

DB.drop_table?(:users_trophies, :trophies_users, :trophies, :scores, :games, :scoretypes, :gameranges_gametypes, :gametypes, :gameranges_operators, :gameranges, :operators, :users)


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
	many_to_many :trophies, :key => :trophy_id

	def self.create(values = {}, &block)
		puts "New User: #{values[:username]}"
		super
	end
end


# - GAME STRUCTURE ------------------------------

unless DB.table_exists?(:operators)
	DB.create_table(:operators) do
		primary_key	:id
		String 		:name, :unique=>true
		String 		:descr
		String		:long_descr
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
    	String    	:long_descr
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

		pod = Array.new
		
		case gt.name
			when "score" 
				pod[0] = 120
				pod[1] = 60
				pod[2] = 30
			when "time"
				pod[0] = 100
				pod[1] = 40
				pod[2] = 20
			when "marathon"
				pod[0] = 40
				pod[1] = 30
				pod[2] = 20
			else
				pod[0] = 1000
				pod[1] = 500
				pod[2] = 250
		end
			

		puts "New Game: " + values[:name]
		newGame = super

		i = 1
		pod.each { |pod|
			Trophy.create(:game_id => newGame.id,
						:min_score => pod,
						:pod => i)
			i+=1
		}
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

	def save
		puts "New Score: #{self.score}"
		addTrophy(self.user_id, self.game_id, self.score)
		super
	end

end



unless DB.table_exists?(:trophies)
	DB.create_table(:trophies) do
		primary_key :id
		foreign_key :game_id, :games
		Integer 	:min_score
		Integer 	:pod
		check(:pod=>[1, 2, 3])
	end
end

class Trophy < Sequel::Model(:trophies)
	many_to_many :users
end


unless DB.table_exists?(:trophies_users)
	DB.create_table(:trophies_users) do
		primary_key	:id
		foreign_key	:user_id, :users
		foreign_key	:trophy_id, :trophies
		unique([:user_id, :trophy_id])
	end
end


# ===============================================
#    DB Data Inserts
# ===============================================


# - USERS ----------------------------------------

User.create(:username=>"hans231", :firstname=>"Hans", :email=>"h.hans@hans.de", :password=>"hallo")
User.create(:username=>"jürgen231", :firstname=>"Jürgen", :email=>"jürgen@jürgen.de", :password=>"hallo")
User.create(:username=>"rüdiger231", :firstname=>"Rüdiger", :email=>"rüdiger@rüdiger.de", :password=>"hallo")

Gamerange.create(:name=>"10", :long_descr=> "Rechne mit den Zahlen von 1-10!")
Gamerange.create(:name=>"20", :long_descr=> "Rechne mit den Zahlen von 1-20!")
Gamerange.create(:name=>"100", :long_descr=> "Rechne mit den Zahlen von 1-100!")
Gamerange.create(:name=>"small", :long_descr=> "Kannst du das kleine Einmaleins?")
Gamerange.create(:name=>"big", :long_descr=> "Kannst du das große Einmaleins?")
Gamerange.create(:name=>"all", :long_descr => "-- Platzhalter -- ")

Operator.create(:name=>"addi", :descr=>"Addition (Plus)", :long_descr=>"Zähle die Zahlen zusammen!")
Operator.create(:name=>"subt", :descr=>"Subtraktion (Minus)", :long_descr=>"Ziehe die Zahlen von einander ab!")
Operator.create(:name=>"mult", :descr=>"Multiplikation (Mal)", :long_descr=>"Rechne mit mal!")
Operator.create(:name=>"divi", :descr=>"Division (Geteilt)", :long_descr =>"Teile die Zahlen durch einander!")
Operator.create(:name=>"mix", :descr=>"Alle gemischt",:long_descr =>"Rechne mit allen Rechenarten!")



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
Game.create(:name=>"time_dummy", 
			:filename=>"time_game_dummy.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")

Score.create(:user_id=>2, 
			:game_id=>3,
			:timestamp => DateTime.now,
			:score => 40)
Score.create(:user_id=>2, 
			:game_id=>1,
			:timestamp => DateTime.now,
			:score => 60)











