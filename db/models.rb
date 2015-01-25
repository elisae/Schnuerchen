# ===============================================
#    DB Model Definitions
# ===============================================


# *************************************************** #
# 												      #
#   Daten einfügen bitte im zweiten Teil (line 192)   #
# 												      #
# *************************************************** #


# - INIT -----------------------------------------

DB.drop_table?(:users_trophies, :friendships, :trophies_users, :trophies, :scores, :games, :scoretypes, :gameranges_gametypes, :gametypes, :gameranges_operators, :gameranges, :operators, :users, :friends)


# - USERS ---------------------------------------
unless DB.table_exists?(:users) 
	DB.create_table(:users) do
		primary_key	:id
		String		:username
		String		:firstname
		String		:email
		String		:salt
		String 		:password_hash
		TrueClass	:admin, :default=>false
	end
end

class User < Sequel::Model(:users)
	many_to_many :trophies
	one_to_many :scores
	many_to_many :friends_with, :left_key=>:friends_with_id, :right_key=>:friend_of_id, :join_table=>:friendships, :class=>self
 	many_to_many :friend_of, :left_key=>:friend_of_id, :right_key=>:friends_with_id, :join_table=>:friendships, :class=>self


	def self.create(values = {}, &block)
		password = values.delete(:password)
		if password
			password_salt = BCrypt::Engine.generate_salt
  			password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  			values = values.merge({:password_hash=>password_hash, :salt=>password_salt})
			puts "New User: #{values[:username]} (from models.rb)"
			super(values)
		else
			puts "New User: #{values[:username]}"
			super
		end
	end
	
	def before_destroy
		self.remove_all_trophies
		self.scores.each { |score|
			score.destroy
		}
		self.remove_all_friend_of
		self.remove_all_friends_with
		super
	end

end

unless DB.table_exists?(:friendships)
	DB.create_table(:friendships) do
		primary_key :id
		foreign_key :friends_with_id
		foreign_key :friend_of_id
		unique([:friends_with_id, :friend_of_id])
	end
end

class Friendship < Sequel::Model(:friendships)
	def self.create(values = {}, &block)
		puts "New Friendship: #{values[:friends_with_id]} -> #{values[:friend_of_id]}"
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
	one_to_many	:games, :key => :operator
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
		String		:descr
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
		String		:descr
		String		:long_descr
		String		:img_filename
		Integer		:pod_1
		Integer		:pod_2
		Integer		:pod_3
	end
end

class Gametype < Sequel::Model(:gametypes)
	many_to_many :gameranges
	one_to_many :games, :key => :gametype_name
end


unless DB.table_exists?(:gameranges_gametypes)
	DB.create_table(:gameranges_gametypes) do
		primary_key	:id
		foreign_key	:gamerange_id, :gameranges
		foreign_key	:gametype_id, :gametypes
		unique([:gamerange_id, :gametype_id])
	end
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
		String		:gametype_name
		unique([:operator, :gamerange, :gametype_name])
		foreign_key [:gametype_name], :gametypes, :key => :name
	end
end

class Game < Sequel::Model(:games)
	many_to_one :gametype, :key => :gametype_name, :primary_key => :name
	# many_to_one :operator, :key => :operator, :primary_key => :name

	# Bei Spielerstellung ensprechende Operator, Range, Typ, Scoretype verknüpfen
	def self.create(values = {}, &block)
		puts "New Game: #{values[:name]}"
		newGame = super

		op = Operator.find_or_create(:name => newGame.operator)
		gr = Gamerange.find_or_create(:name => newGame.gamerange)
		gt = newGame.gametype
		unless op.gameranges.include?(gr)
			op.add_gamerange(gr)
		end
		unless gr.gametypes.include?(gt)
			gr.add_gametype(gt)
		end

		Trophy.create(:game_id => newGame.id,
					  :min_score => newGame.gametype.pod_1,
					  :pod => 1)
		Trophy.create(:game_id => newGame.id,
					  :min_score => newGame.gametype.pod_2,
					  :pod => 2)
		Trophy.create(:game_id => newGame.id,
					  :min_score => newGame.gametype.pod_3,
					  :pod => 3)

		return newGame
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
	many_to_one :user

	def save
		puts "New Score: #{self.score}"
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


# - DEFAULTUSERS ----------------------------------------
User.create(:username=>"hans231", :firstname=>"Hans", :email=>"h.hans@hans.de", :password=>"hallo", :admin=>true)
User.create(:username=>"kenny", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")
User.create(:username=>"kenner", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")
User.create(:username=>"kennster", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")
User.create(:username=>"kennmer", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")

Friendship.create(:friends_with_id => 1, :friend_of_id => 2)
Friendship.create(:friends_with_id => 2, :friend_of_id => 1)
Friendship.create(:friends_with_id => 1, :friend_of_id => 3)
Friendship.create(:friends_with_id => 1, :friend_of_id => 4)


# - OPERATORS -------------------------------
Operator.create(:name=>"addi", 
				:descr=>"Addition (Plus)", 
				:long_descr=>"Zähle die Zahlen zusammen!",
				:img_filename=>"addition-icon.png")
Operator.create(:name=>"subt", 
				:descr=>"Subtraktion (Minus)", 
				:long_descr=>"Ziehe die Zahlen von einander ab!",
				:img_filename=>"substraction-icon.png")
Operator.create(:name=>"mult", 
				:descr=>"Multiplikation (Mal)", 
				:long_descr=>"Rechne mit mal!",
				:img_filename=>"multiplikation-icon.png")
Operator.create(:name=>"divi", 
				:descr=>"Division (Geteilt)", 
				:long_descr =>"Teile die Zahlen durch einander!",
				:img_filename=>"division-icon.png")
Operator.create(:name=>"mix", 
				:descr=>"Alle gemischt",
				:long_descr =>"Rechne mit allen Rechenarten!",
				:img_filename=>"mixed-icon.png")

# - GAMERANGES --------------------------
Gamerange.create(:name=>"10",
				 :descr=>"Zahlen bis 10",
				 :long_descr=> "Rechne mit den Zahlen von 1-10!",
				 :img_filename=>"range-10-icon.png")
Gamerange.create(:name=>"20", 
				 :descr=>"Zahlen bis 20",
				 :long_descr=> "Rechne mit den Zahlen von 1-20!",
				 :img_filename=>"range-20-icon.png")
Gamerange.create(:name=>"100", 
				 :descr=>"Zahlen bis 100",
				 :long_descr=> "Rechne mit den Zahlen von 1-100!",
				 :img_filename=>"range-100-icon.png")
Gamerange.create(:name=>"small", 
				 :descr=>"Kleines Einmaleins",
				 :long_descr=> "Kannst du das kleine Einmaleins?",
				 :img_filename=>"small.png")
Gamerange.create(:name=>"big", 
				 :descr=>"Großes Einmaleins",
				 :long_descr=> "Kannst du das große Einmaleins?",
				 :img_filename=>"big.png")

# - GAMETYPES ---------------------------------
Gametype.create(:name=>"choice", 
				:descr=>"Auswahl", 
				:long_descr=>"Wähl die richtige Antwort aus",
				:img_filename=>"choice.png",
				:pod_1=>190,
				:pod_2=>170,
				:pod_3=>120)
Gametype.create(:name=>"score", 
				:descr=>"Highscore",
				:long_descr=>"Finde so schnell wie möglich die richtigen Lösungen",
				:img_filename=>"score.png",
				:pod_1=>193,
				:pod_2=>170,
				:pod_3=>100)
Gametype.create(:name=>"time", 
				:descr=>"Countdown", 
				:long_descr=>"Löse so viele Aufgaben wie möglich, bis die Zeit abgelaufen ist",
				:img_filename=>"time.png",
				:pod_1=>400,
				:pod_2=>200,
				:pod_3=>100)
Gametype.create(:name=>"marathon", 
				:descr=>"Marathon", 
				:long_descr=>"Wie lange hältst du durch? Für jede richtige Aufgabe bekommst du Bonus-Zeit, für jede falsche Zeit-Abzug.",
				:img_filename=>"marathon.png",
				:pod_1=>1000,
				:pod_2=>700,
				:pod_3=>200)


# - GAMES ----------------------------------------

# Choice Addi--------------------------------
Game.create(:name=>"Choice Addi 20", 
			:filename=>"game_choice_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Choice Addi 100", 
			:filename=>"game_choice_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
# Choice Subt--------------------------------
Game.create(:name=>"Choice Subt 20", 
			:filename=>"game_choice_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Choice Subt 100", 
			:filename=>"game_choice_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
# Choice Mult--------------------------------
Game.create(:name=>"Choice Mult Small", 
			:filename=>"game_choice_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Choice Mult Big", 
			:filename=>"game_choice_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
# Choice Divi--------------------------------
Game.create(:name=>"Choice Divi Small", 
			:filename=>"game_choice_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Choice Divi Big", 
			:filename=>"game_choice_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
#Score Addi ------------------------------------------
Game.create(:name=>"Addi 10", 
			:filename=>"game_n_addi_10.js", 
			:operator=>"addi", 
			:gamerange=>"10", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Addi 20", 
			:filename=>"game_n_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Addi 100", 
			:filename=>"game_n_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Score Subt -------------------------------------------
Game.create(:name=>"Subt 10", 
			:filename=>"game_n_subt_10.js", 
			:operator=>"subt", 
			:gamerange=>"10", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Subt 20", 
			:filename=>"game_n_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Subt 100", 
			:filename=>"game_n_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Score Mult -------------------------------------
Game.create(:name=>"Mult Small", 
			:filename=>"game_n_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Mult Big", 
			:filename=>"game_n_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Score Divi -------------------------------------
Game.create(:name=>"Divi Small", 
			:filename=>"game_n_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Divi Big", 
			:filename=>"game_n_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
#Score Mix ------------------------------------------
Game.create(:name=>"Score Mix 100", 
			:filename=>"game_n_mix_100.js", 
			:operator=>"mix", 
			:gamerange=>"100", 
			:gametype_name=>"score",  
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Score Mix 20", 
			:filename=>"game_n_mix_20.js", 
			:operator=>"mix", 
			:gamerange=>"20", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Marathon Addi ----------------------------------------
Game.create(:name=>"Marathon Addi 20", 
			:filename=>"game_marathon_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Addi 100", 
			:filename=>"game_marathon_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Marathon Subt ------------------------------------------
Game.create(:name=>"Marathon Subt 20", 
			:filename=>"game_marathon_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Subt 100", 
			:filename=>"game_marathon_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Marathon Mult -------------------------------------------
Game.create(:name=>"Marathon Mult Small", 
			:filename=>"game_marathon_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Mult Big", 
			:filename=>"game_marathon_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Marathon Div -------------------------------------------
Game.create(:name=>"Marathon Divi Small", 
			:filename=>"game_marathon_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Mult Big", 
			:filename=>"game_marathon_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
#Marathon Mix ------------------------------------------
Game.create(:name=>"Marathon Mix 100", 
			:filename=>"game_marathon_mix_100.js", 
			:operator=>"mix", 
			:gamerange=>"100", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Mix 20", 
			:filename=>"game_marathon_mix_20.js", 
			:operator=>"mix", 
			:gamerange=>"20", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Time Addi -----------------------------------------------

Game.create(:name=>"Time Addi 20", 
			:filename=>"game_time_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Addi 100", 
			:filename=>"game_time_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
# Time Subt -----------------------------------------------

Game.create(:name=>"Time Subt 20", 
			:filename=>"game_time_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Subt 100", 
			:filename=>"game_time_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
# Time Mult ---------------------------------------------
Game.create(:name=>"Time Mult Small", 
			:filename=>"game_time_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Mult Big", 
			:filename=>"game_time_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
# Time Divi ---------------------------------------------
Game.create(:name=>"Time Divi Small", 
			:filename=>"game_time_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Divi Big", 
			:filename=>"game_time_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
#Time Mix ------------------------------------------
Game.create(:name=>"Time Mix 100", 
			:filename=>"game_time_mix_100.js", 
			:operator=>"mix", 
			:gamerange=>"100", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Mix 20", 
			:filename=>"game_time_mix_20.js", 
			:operator=>"mix", 
			:gamerange=>"20", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")

