require "test/unit"
require "contest"
require "rr"
require "rack/test"
require "ruby-debug"
require "integrity/notifier/test"

require File.dirname(__FILE__) + "/../lib/bobette"
require File.dirname(__FILE__) + "/../lib/integrity/buildable_project"
require File.dirname(__FILE__) + "/helper/git_helper"

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
  include TestHelper

  def app
    Bobette::App.tap { |app| app.set(:environment, :test) }
  end
end
