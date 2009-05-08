require File.dirname(__FILE__) + "/helper"

class BobetteTest < BobetteTestCase
  def payload(commits, url)
    { "ref"        => "refs/heads/master",
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
    post("/", :payload => payload(@repo.commits, @repo.path))

    assert_equal 2, @project.commits.count
    assert_equal :failed, @project.status
    assert @project.commits.last.output.include?("No such file")

    @repo.add_successful_commit
    post("/", :payload => payload([@repo.commits.first], @repo.path))

    assert_equal :success, @project.status
  end

  test "400 with invalid JSON" do
    assert post("/").client_error?
    assert post("/", :payload => "</3").client_error?
  end
end
