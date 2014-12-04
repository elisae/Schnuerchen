# - Load path and gems/bundler ------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require "bundler"
Bundler.require

# - Local config --------------------------------------------
require "find"

%w{helpers db}.each do |load_path|
	Find.find(load_path) { |f|
		require f unless !f.match(/\.rb$/) || File.directory?(f)
	}
end

# - Other ---------------------------------------------------
require "sequel"
require "sinatra/json"
require "pp"

# - Load app ------------------------------------------------
require "app"
run App
