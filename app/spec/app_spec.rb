require_relative "spec_helper"
require_relative "../app.rb"

def app
  App
end

describe App do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
