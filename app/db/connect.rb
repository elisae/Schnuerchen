# DB Connection
settings = {
	development: "postgres://Willi:schnuerchen@localhost:5432/schnuerchen_dev",
	test: "postgres://Willi:schnuerchen@localhost:5432/schnuerchen_test"	
	# eigentlich reicht schnuerchen_dev erstmal auch
}



# Sequel Configuration
# DB = Sequel.connect(settings[ENV['RACK_ENV']]) ----- für später, ENV Variable test/development mitgeben

# bis dahin:
DB = Sequel.connect("postgres://postgres:schnuerchen@localhost:5432/schnuerchen_dev")