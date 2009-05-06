require "test/unit"
require "contest"
require "rr"
require "rack/test"

require File.dirname(__FILE__) + "/../lib/bobette"

class FakeBuildable
  def initialize(payload); end

  def uri
    "git://github.com/foo/bar.git"
  end

  def branch
    "master"
  end

  def kind
    :git
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
