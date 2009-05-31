require "test/unit"
require "rack/test"
require "beacon"

begin
  require "ruby-debug"
  require "redgreen"
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "bobette"
require "bobette/json"

require "helper/buildable_stub"
require "helper/scm/git"

class Test::Unit::TestSuite
  def empty?
    false
  end
end

class Bobette::TestCase < Test::Unit::TestCase
  include Rack::Test::Methods
  include TestHelper

  def app
    @app ||= Rack::Builder.new {
      use Bobette::JSON
      use Rack::Lint
      run Bobette.new(BuildableStub)
    }
  end

  def payload(repo, branch="master")
    { "branch"  => branch,
      "commits" => repo.commits.map { |c| {"id" => c[:identifier]} },
      "uri"     => repo.path }
  end
end

