
unless DB.table_exists? (:user) do
	DB.create_table :user
		primary_key	:id
		string		:username
		string		:firstname
		integer		:age
	end
end

class User < Sequel::Model(:user)
end
