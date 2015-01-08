# DB Connection
settings = {
	development: "postgres://postgres@localhost/schnuerchen_dev",
	test: "postgres://postgres@localhost/schnuerchen_test"	
	# eigentlich reicht schnuerchen_dev erstmal auch
}



# Sequel Configuration
# DB = Sequel.connect(settings[ENV['RACK_ENV']]) ----- für später, ENV Variable test/development mitgeben

# bis dahin:
DB = Sequel.connect("postgres://postgres:lol@localhost/schnuerchen_dev")
