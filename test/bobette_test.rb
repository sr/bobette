require "test/unit"
require "contest"
require "rack/test"
require "integrity/notifier/test"

begin
  require "ruby-debug"
  require "redgreen"
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "bobette"
require "integrity/buildable_project"

require "helper/git_helper"

class BobetteTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include TestHelper

  def app
    Bobette::App.tap { |app| app.set(:environment, :test) }
  end

  def payload(commits, url, branch="master")
    { "ref"        => "refs/heads/#{branch}",
      "commits"    => commits.map { |c| { "id" => c[:identifier] } },
      "repository" => {"url" => url} }.to_json
  end

  setup do
    DataMapper.setup(:default, "sqlite3::memory:")
    DataMapper.auto_migrate!

    Bob.logger = Logger.new("/dev/null")
    Bob.directory = File.expand_path(File.dirname(__FILE__))

    Bobette.buildable = Integrity::BuildableProject

    @repo = GitRepo.new(:my_test_project)
    @repo.create
    @repo.add_failing_commit

    @project = Integrity::Project.gen(:my_test_project, :uri => @repo.path)
  end

  teardown do
    FileUtils.rm_rf(@repo.path)
  end

  test "building an Integrity::BuildableProject" do
    assert post("/", :payload => payload(@repo.commits, @repo.path)).ok?

    assert_equal 2, @project.commits.count

    commit = @project.commits.first(:identifier => @repo.commits.last[:identifier])
    assert_equal "This commit will fail", commit.message
    assert_equal :failed,                 commit.status
    assert_equal "Running tests...\n",    commit.output

    @repo.add_successful_commit
    post("/", :payload => payload([@repo.commits.last], @repo.path))

    assert_equal 3, @project.commits.count
    assert_equal "This commit will work", @project.last_commit.message
    assert_equal :success, @project.status
  end

  test "ignores branches that aren't watched by associated project" do
    post("/", :payload => payload(@repo.commits, @repo.path, "foo")) {
      |response| assert response.ok? }

    assert_equal 0, @project.commits.count
  end

  test "400 with invalid JSON" do
    assert post("/").client_error?
    assert post("/", :payload => "</3").client_error?
  end
end
