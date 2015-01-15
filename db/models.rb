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

DB.drop_table?(:users_trophies, :friendships, :trophies_users, :trophies, :scores, :games, :scoretypes, :gameranges_gametypes, :gametypes, :gameranges_operators, :gameranges, :operators, :users, :friends)


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

	many_to_many :friends_with, :left_key=>:friends_with_id, :right_key=>:friend_of_id, :join_table=>:friendships, :class=>self
 	many_to_many :friend_of, :left_key=>:friend_of_id, :right_key=>:friends_with_id, :join_table=>:friendships, :class=>self

	def self.create(values = {}, &block)
		puts "New User: #{values[:username]}"
		super
	end
end

# unless DB.table_exists?(:friends)
#   DB.create_table(:friends) do
#     primary_key :id
#     foreign_key :user_id
#     foreign_key :friend_id
#   end
# end

# class Friend < Sequel::Model(:friends)
#   one_to_many :user_id
#   one_to_many :friend_id
# end

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
			when "choice"
				pod[0] = 100
				pod[1] = 40
				pod[2] = 20	
			when "marathon"
				pod[0] = 90
				pod[1] = 60
				pod[2] = 30
			when "choice"
				pod[0] = 90
				pod[1] = 60
				pod[2] = 30
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
User.create(:username=>"kenny", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")
User.create(:username=>"kenner", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")
User.create(:username=>"kennster", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")
User.create(:username=>"kennmer", :firstname=>"kenny", :email=>"kenny@kenny.de", :password=>"hallo")

# Friend.create(:user_id=>"1", :friend_id=>"2")
# Friend.create(:user_id=>"1", :friend_id=>"3")
# Friend.create(:user_id=>"2", :friend_id=>"1")
# Friend.create(:user_id=>"3", :friend_id=>"1")
# Friend.create(:user_id=>"1", :friend_id=>"4")
# Friend.create(:user_id=>"2", :friend_id=>"3")

Friendship.create(:friends_with_id => 1, :friend_of_id => 2)
Friendship.create(:friends_with_id => 2, :friend_of_id => 1)

Friendship.create(:friends_with_id => 1, :friend_of_id => 3)
Friendship.create(:friends_with_id => 1, :friend_of_id => 4)
Friendship.create(:friends_with_id => 5, :friend_of_id => 1)

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

# Choice Addi--------------------------------
Game.create(:name=>"Choice Addi 20", 
			:filename=>"game_choice_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype=>"choice", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Choice Addi 100", 
			:filename=>"game_choice_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype=>"choice", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Score Addi ------------------------------------------
Game.create(:name=>"Addi 10", 
			:filename=>"game_n_addi_10.js", 
			:operator=>"addi", 
			:gamerange=>"10", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Addi 20", 
			:filename=>"game_n_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Addi 100", 
			:filename=>"game_n_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Score Subt -------------------------------------------
Game.create(:name=>"Subt 10", 
			:filename=>"game_n_subt_10.js", 
			:operator=>"subt", 
			:gamerange=>"10", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Subt 20", 
			:filename=>"game_n_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Subt 100", 
			:filename=>"game_n_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Score Mult -------------------------------------
Game.create(:name=>"Mult Small", 
			:filename=>"game_n_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Mult Big", 
			:filename=>"game_n_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Score Divi -------------------------------------
Game.create(:name=>"Divi Small", 
			:filename=>"game_n_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Divi Big", 
			:filename=>"game_n_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype=>"score", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Marathon Addi ----------------------------------------
Game.create(:name=>"Marathon Addi 20", 
			:filename=>"game_marathon_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Addi 100", 
			:filename=>"game_marathon_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Marathon Subt ------------------------------------------
Game.create(:name=>"Marathon Subt 20", 
			:filename=>"game_marathon_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Subt 100", 
			:filename=>"game_marathon_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Marathon Mult -------------------------------------------
Game.create(:name=>"Marathon Mult Small", 
			:filename=>"game_marathon_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Mult Big", 
			:filename=>"game_marathon_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Marathon Div -------------------------------------------
Game.create(:name=>"Marathon Divi Small", 
			:filename=>"game_marathon_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Marathon Mult Big", 
			:filename=>"game_marathon_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
			:gametype=>"marathon", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Time Addi -----------------------------------------------

Game.create(:name=>"Time Addi 20", 
			:filename=>"game_time_addi_20.js", 
			:operator=>"addi", 
			:gamerange=>"20", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Addi 100", 
			:filename=>"game_time_addi_100.js", 
			:operator=>"addi", 
			:gamerange=>"100", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Time Subt -----------------------------------------------

Game.create(:name=>"Time Subt 20", 
			:filename=>"game_time_subt_20.js", 
			:operator=>"subt", 
			:gamerange=>"20", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Subt 100", 
			:filename=>"game_time_subt_100.js", 
			:operator=>"subt", 
			:gamerange=>"100", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Time Mult ---------------------------------------------
Game.create(:name=>"Time Mult Small", 
			:filename=>"game_time_mult_small.js", 
			:operator=>"mult", 
			:gamerange=>"small", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Mult Big", 
			:filename=>"game_time_mult_big.js", 
			:operator=>"mult", 
			:gamerange=>"big", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
# Time Divi ---------------------------------------------
Game.create(:name=>"Time Divi Small", 
			:filename=>"game_time_divi_small.js", 
			:operator=>"divi", 
			:gamerange=>"small", 
			:gametype=>"time", 
			:scoretype=>"points", 
			:css_filename=>"dummygamestyle.css")
Game.create(:name=>"Time Divi Big", 
			:filename=>"game_time_divi_big.js", 
			:operator=>"divi", 
			:gamerange=>"big", 
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
Score.create(:user_id=>1,
             :game_id=>1,
             :timestamp => DateTime.now,
             :score => 60)
Score.create(:user_id=>1,
             :game_id=>3,
             :timestamp => DateTime.now,
             :score => 100)
Score.create(:user_id=>1,
             :game_id=>2,
             :timestamp => DateTime.now,
             :score => 100)