require "test/unit"
require "contest"
require "rack/test"
require "ruby-debug"
require "integrity/notifier/test"

require File.dirname(__FILE__) + "/../lib/bobette"
require File.dirname(__FILE__) + "/../lib/integrity/buildable_project"
require File.dirname(__FILE__) + "/helper/git_helper"

class BobetteTestCase < Test::Unit::TestCase
  class << self
    alias_method :it, :test
  end

  include Rack::Test::Methods
  include TestHelper

  def app
    Bobette::App.tap { |app| app.set(:environment, :test) }
  end
end
