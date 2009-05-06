require "test/unit"
require "contest"
require "rr"
require "rack/test"

require File.dirname(__FILE__) + "/../lib/bobette"

class FakeBuildable
  def initialize(payload)
    @payload = payload
  end

  def uri
    @payload["repository"]["url"]
  end

  def kind
    URI(uri).scheme
  end

  def branch
    @payload["ref"].split("/").last
  end
end

class BobetteTestCase < Test::Unit::TestCase
  class << self
    alias_method :it, :test
  end

  include RR::Adapters::TestUnit
  include Rack::Test::Methods

  def app
    Bobette::App.tap { |app| app.set(:environment, :test) }
  end
end
