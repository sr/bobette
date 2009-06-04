require File.dirname(__FILE__) + "/helper"

require "bobette/token"

class BobetteTokenTest < Bobette::TestCase
  def app
    Rack::Builder.new {
      use Bobette::Token do |token|
        token == "secret"
      end
      use Rack::Lint
      run proc { |env| [200, {"Content-Type" => "text/html"}, ["foo"]] }
    }
  end

  def test_token
    assert get("/").forbidden?
    assert get("/foo").forbidden?
    assert get("/secret").ok?
  end
end
