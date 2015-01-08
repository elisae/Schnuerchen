<<<<<<< HEAD
﻿# DB Connection
settings = {
	development: "postgres://postgres@localhost/schnuerchen_dev",
	test: "postgres://postgres@localhost/schnuerchen_test"	
=======
# DB Connection
settings = {
	development: "postgres://Willi:schnuerchen@localhost:5432/schnuerchen_dev",
	test: "postgres://Willi:schnuerchen@localhost:5432/schnuerchen_test"	
>>>>>>> 2eb607f03fced746cd95512b8fb0f1b9812d9911
	# eigentlich reicht schnuerchen_dev erstmal auch
}



# Sequel Configuration
# DB = Sequel.connect(settings[ENV['RACK_ENV']]) ----- für später, ENV Variable test/development mitgeben

# bis dahin:
<<<<<<< HEAD
DB = Sequel.connect("postgres://postgres:lol@localhost/schnuerchen_dev")
=======
DB = Sequel.connect("postgres://postgres:schnuerchen@localhost:5432/schnuerchen_dev")
>>>>>>> 2eb607f03fced746cd95512b8fb0f1b9812d9911
