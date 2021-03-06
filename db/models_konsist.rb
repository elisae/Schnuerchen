# ===============================================
#    DB Model Definitions
# ===============================================


# *************************************************** #
# 												      #
#   Daten einfügen bitte im zweiten Teil (line 192)   #
# 												      #
# *************************************************** #


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
		puts "Destroying User #{self.id} (#{self.username})"
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

	def before_destroy
		puts "Destroying Operator #{self.name}"
		if Game.where(:operator=>self.name).empty?
			self.remove_all_gameranges
			super
		else
			return false
		end
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

	def before_destroy
		puts "Destroying Gamerange #{self.name}"
		if Game.where(:gamerange=>self.name).empty?
			self.remove_all_gametypes
			self.remove_all_operators
			super
		else
			return false
		end
	end
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

	def before_destroy
		puts "Destroying Gametype #{self.name}"
		if Game.where(:gametype_name=>self.name).empty?
			self.remove_all_gameranges
			super
		else
			return false
		end
	end

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
	one_to_many :trophies
	one_to_many :scores

	# Bei Spielerstellung ensprechende Operator, Range, Typ verknüpfen
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

		Trophy.find_or_create(:game_id => newGame.id,
					  :min_score => newGame.gametype.pod_1,
					  :pod => 1)
		Trophy.find_or_create(:game_id => newGame.id,
					  :min_score => newGame.gametype.pod_2,
					  :pod => 2)
		Trophy.find_or_create(:game_id => newGame.id,
					  :min_score => newGame.gametype.pod_3,
					  :pod => 3)

		return newGame
	end


	def around_destroy
		puts "Destroying Game #{self.name}"
		gamerange = Gamerange.first(:name => self.gamerange)
		gamerange.remove_gametype(self.gametype)
		operator = Operator.first(:name => self.operator)
		unless gamerange.gametypes.any?
			operator.remove_gamerange(gamerange)
			puts "Gamerange removed"
		end

		self.scores.each{ |score|
			score.destroy
		}
		self.trophies.each{ |trophy|
			trophy.destroy
		}

		super

		begin
			operator.destroy
			puts "Operator deleted"
		rescue Sequel::HookFailed
			puts "Operator still has games"
		end
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
	many_to_one :game

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
	many_to_one :game

	def before_destroy
		puts "Destroying Trophy #{self.id} for Game #{self.game_id}"
		self.users.each { |user|
			user.remove_trophy(self)
		}
	end
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





# - OPERATORS -------------------------------
Operator.find_or_create(:name=>"addi", 
				:descr=>"Addition (Plus)", 
				:long_descr=>"Zähle die Zahlen zusammen!",
				:img_filename=>"addition-icon.png")
Operator.find_or_create(:name=>"subt", 
				:descr=>"Subtraktion (Minus)", 
				:long_descr=>"Ziehe die Zahlen von einander ab!",
				:img_filename=>"substraction-icon.png")
Operator.find_or_create(:name=>"mult", 
				:descr=>"Multiplikation (Mal)", 
				:long_descr=>"Rechne mit mal!",
				:img_filename=>"multiplikation-icon.png")
Operator.find_or_create(:name=>"divi", 
				:descr=>"Division (Geteilt)", 
				:long_descr =>"Teile die Zahlen durch einander!",
				:img_filename=>"division-icon.png")
Operator.find_or_create(:name=>"mix", 
				:descr=>"Alle gemischt",
				:long_descr =>"Rechne mit allen Rechenarten!",
				:img_filename=>"mixed-icon.png")


# - GAMERANGES --------------------------
Gamerange.find_or_create(:name=>"10",
				 :descr=>"Zahlen bis 10",
				 :long_descr=> "Rechne mit den Zahlen von 1-10!",
				 :img_filename=>"range-10-icon.png")
Gamerange.find_or_create(:name=>"20", 
				 :descr=>"Zahlen bis 20",
				 :long_descr=> "Rechne mit den Zahlen von 1-20!",
				 :img_filename=>"range-20-icon.png")
Gamerange.find_or_create(:name=>"100", 
				 :descr=>"Zahlen bis 100",
				 :long_descr=> "Rechne mit den Zahlen von 1-100!",
				 :img_filename=>"range-100-icon.png")
Gamerange.find_or_create(:name=>"small", 
				 :descr=>"Kleines Einmaleins",
				 :long_descr=> "Kannst du das kleine Einmaleins?",
				 :img_filename=>"small.png")
Gamerange.find_or_create(:name=>"big", 
				 :descr=>"Großes Einmaleins",
				 :long_descr=> "Kannst du das große Einmaleins?",
				 :img_filename=>"big.png")

# - GAMETYPES ---------------------------------
Gametype.find_or_create(:name=>"choice", 
				:descr=>"Auswahl", 
				:long_descr=>"Wähl die richtige Antwort aus",
				:img_filename=>"choice.png",
				:pod_1=>190,
				:pod_2=>170,
				:pod_3=>120)
Gametype.find_or_create(:name=>"score", 
				:descr=>"Highscore",
				:long_descr=>"Finde so schnell wie möglich die richtigen Lösungen",
				:img_filename=>"score.png",
				:pod_1=>193,
				:pod_2=>170,
				:pod_3=>100)
Gametype.find_or_create(:name=>"time", 
				:descr=>"Countdown", 
				:long_descr=>"Löse so viele Aufgaben wie möglich, bis die Zeit abgelaufen ist",
				:img_filename=>"time.png",
				:pod_1=>400,
				:pod_2=>200,
				:pod_3=>100)
Gametype.find_or_create(:name=>"marathon", 
				:descr=>"Marathon", 
				:long_descr=>"Wie lange hältst du durch? Für jede richtige Aufgabe bekommst du Bonus-Zeit, für jede falsche Zeit-Abzug.",
				:img_filename=>"marathon.png",
				:pod_1=>1000,
				:pod_2=>700,
				:pod_3=>200)

# - GAMES ----------------------------------------

# Choice Addi--------------------------------
Game.find_or_create(:name=>"Choice Addi 20", 
			:filename=>"game_choice_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Choice Addi 100", 
			:filename=>"game_choice_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
# Choice Subt--------------------------------
Game.find_or_create(:name=>"Choice Subt 20", 
			:filename=>"game_choice_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Choice Subt 100", 
			:filename=>"game_choice_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
# Choice Mult--------------------------------
Game.find_or_create(:name=>"Choice Mult Small", 
			:filename=>"game_choice_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Choice Mult Big", 
			:filename=>"game_choice_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
# Choice Divi--------------------------------
Game.find_or_create(:name=>"Choice Divi Small", 
			:filename=>"game_choice_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Choice Divi Big", 
			:filename=>"game_choice_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"choice", 
			:css_filename=>"dummygamestyle.css")
#Score Addi ------------------------------------------
Game.find_or_create(:name=>"Addi 10", 
			:filename=>"game_n_addi_10.js", 
			:operator=>"addi", 
			:gamerange=>"10", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Addi 20", 
			:filename=>"game_n_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Addi 100", 
			:filename=>"game_n_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Score Subt -------------------------------------------
Game.find_or_create(:name=>"Subt 10", 
			:filename=>"game_n_subt_10.js", 
			:operator=>"subt", 
			:gamerange=>"10", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Subt 20", 
			:filename=>"game_n_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Subt 100", 
			:filename=>"game_n_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Score Mult -------------------------------------
Game.find_or_create(:name=>"Mult Small", 
			:filename=>"game_n_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Mult Big", 
			:filename=>"game_n_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Score Divi -------------------------------------
Game.find_or_create(:name=>"Divi Small", 
			:filename=>"game_n_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Divi Big", 
			:filename=>"game_n_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
#Score Mix ------------------------------------------
Game.find_or_create(:name=>"Score Mix 100", 
			:filename=>"game_n_mix_100.js", 
			:operator=>"mix", 
			:gamerange=>"100", 
			:gametype_name=>"score",  
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Score Mix 20", 
			:filename=>"game_n_mix_20.js", 
			:operator=>"mix", 
			:gamerange=>"20", 
			:gametype_name=>"score", 
			:css_filename=>"dummygamestyle.css")
# Marathon Addi ----------------------------------------
Game.find_or_create(:name=>"Marathon Addi 20", 
			:filename=>"game_marathon_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Marathon Addi 100", 
			:filename=>"game_marathon_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Marathon Subt ------------------------------------------
Game.find_or_create(:name=>"Marathon Subt 20", 
			:filename=>"game_marathon_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Marathon Subt 100", 
			:filename=>"game_marathon_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Marathon Mult -------------------------------------------
Game.find_or_create(:name=>"Marathon Mult Small", 
			:filename=>"game_marathon_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Marathon Mult Big", 
			:filename=>"game_marathon_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Marathon Div -------------------------------------------
Game.find_or_create(:name=>"Marathon Divi Small", 
			:filename=>"game_marathon_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Marathon Mult Big", 
			:filename=>"game_marathon_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
#Marathon Mix ------------------------------------------
Game.find_or_create(:name=>"Marathon Mix 100", 
			:filename=>"game_marathon_mix_100.js", 
			:operator=>"mix", 
			:gamerange=>"100", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Marathon Mix 20", 
			:filename=>"game_marathon_mix_20.js", 
			:operator=>"mix", 
			:gamerange=>"20", 
			:gametype_name=>"marathon", 
			:css_filename=>"dummygamestyle.css")
# Time Addi -----------------------------------------------

Game.find_or_create(:name=>"Time Addi 20", 
			:filename=>"game_time_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Time Addi 100", 
			:filename=>"game_time_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
# Time Subt -----------------------------------------------

Game.find_or_create(:name=>"Time Subt 20", 
			:filename=>"game_time_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Time Subt 100", 
			:filename=>"game_time_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
# Time Mult ---------------------------------------------
Game.find_or_create(:name=>"Time Mult Small", 
			:filename=>"game_time_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Time Mult Big", 
			:filename=>"game_time_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
# Time Divi ---------------------------------------------
Game.find_or_create(:name=>"Time Divi Small", 
			:filename=>"game_time_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Time Divi Big", 
			:filename=>"game_time_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
#Time Mix ------------------------------------------
Game.find_or_create(:name=>"Time Mix 100", 
			:filename=>"game_time_mix_100.js", 
			:operator=>"mix", 
			:gamerange=>"100", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")
Game.find_or_create(:name=>"Time Mix 20", 
			:filename=>"game_time_mix_20.js", 
			:operator=>"mix", 
			:gamerange=>"20", 
			:gametype_name=>"time", 
			:css_filename=>"dummygamestyle.css")