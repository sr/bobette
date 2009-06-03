require "test/unit"
require "rack/test"
require "beacon"
require "bob/test"

begin
  require "ruby-debug"
  require "redgreen"
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "bobette"

class Test::Unit::TestSuite
  def empty?
    false
  end
end

require "helper/buildable_stub"

class Bobette::TestCase < Test::Unit::TestCase
  include Rack::Test::Methods
  include TestHelper
  include Bob::Test

  def app
    @app ||= Rack::Builder.new {
      use Rack::Lint
      run Bobette.new(TestHelper::BuildableStub)
    }
  end

  def payload(repo, branch="master")
    { "branch"  => branch,
      "commits" => repo.commits.map { |c| {"id" => c[:identifier]} },
      "uri"     => repo.path,
      "kind"    => "git" }
  end
end

