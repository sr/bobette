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

  def setup
    Bob.logger = Logger.new("/dev/null")
    Bob.directory = File.expand_path(File.dirname(__FILE__))

    @repo = GitRepo.new(:my_test_project)
    @repo.create
    3.times { |i|
      i.odd? ? @repo.add_successful_commit : @repo.add_failing_commit
    }
  end

  def teardown
    @repo.destroy
  end

  def app
    @app ||= Rack::Lint.new(Bobette.new(BuildableStub))
  end

  def payload(repo, branch="master")
    { "branch"  => branch,
      "commits" => repo.commits.map { |c| {"id" => c[:identifier]} },
      "uri"     => repo.path }
  end
end

