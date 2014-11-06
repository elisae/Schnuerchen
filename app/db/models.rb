Sequel::Model.plugin :json_serializer


# - USERS ----------------------------------------
unless DB.table_exists?(:users) 
	DB.create_table :users do
		primary_key	:id
		String		:username
		String		:firstname
		Integer		:age
	end
end

class User < Sequel::Model(:users)
	
end
