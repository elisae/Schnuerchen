Sequel::Model.plugin :json_serializer

# - INIT -----------------------------------------



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
		primary_key :id
		String 		:descr
	end
end

class Scoretype < Sequel::Model(:scoretypes)
end


unless DB.table_exists?(:gamecats)
	DB.create_table :gamecats do
		primary_key :id
		String 		:descr
	end
end

class Gamecat < Sequel::Model(:gamecats)
end


unless DB.table_exists?(:games)
	DB.create_table(:games) do
		primary_key	:id
		String		:name 
		foreign_key	:gc_id, :gamecats
		foreign_key :st_id, :scoretypes
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
		unique[:u_id, :g_id, :timestamp]
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
		check{1 <= pod <= 3}
	end
end

class Trophy < Sequel::Model(:trophies)
	many_to_many :users
end










