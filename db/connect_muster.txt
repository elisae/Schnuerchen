# DB Connection
settings = {
	development: "postgres://<user>@localhost/schnuerchen_dev",
	test: "postgres://<user>@localhost/schnuerchen_test"	
	# eigentlich reicht schnuerchen_dev erstmal auch
}



# Sequel Configuration
# DB = Sequel.connect(settings[ENV['RACK_ENV']]) ----- für später, ENV Variable test/development mitgeben

# bis dahin:
DB = Sequel.connect("postgres://<user>@localhost/schnuerchen_dev")
