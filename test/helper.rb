require "test/unit"
require "rack/test"
require "beacon"
require "bob/test"

begin
  require "ruby-debug"
  require "redgreen"
rescue LoadError
end

require "bobette"

class Test::Unit::TestSuite
  def empty?
    false
  end
end

require "helper/builder_stub"

class Bobette::TestCase < Test::Unit::TestCase
  include Rack::Test::Methods
  include Bob::Test
  include Bobette::TestHelper

  def setup
    Bob.logger    = Logger.new("/dev/null")
    Bob.directory = File.dirname(__FILE__) + "/../tmp"

    FileUtils.mkdir(Bob.directory)

    BuilderStub.no_buildable = false
  end

  def teardown
    FileUtils.rm_rf(Bob.directory)
  end
end

