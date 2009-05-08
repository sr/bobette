require File.dirname(__FILE__) + "/helper"

class BobetteTest < BobetteTestCase
  def payload
    { "ref"        => "refs/heads/master",
      "commits"    => [{"id" => "8667fbb"}],
      "repository" => {"url" => "git://github.com/sr/bobette.git"} }
  end

  setup do
    Bobette.buildable = FakeBuildable

    @buildable = FakeBuildable.new(payload)
  end

  it "makes a buildable from the payload and builds it with Bob" do
    stub(FakeBuildable).new(payload) { @buildable }
    stub(Bob).build(@buildable, ["8667fbb"]) { nil }

    assert post("/", :payload => payload.to_json).ok?
  end

  test "400 with invalid JSON" do
    assert post("/").client_error?
    assert post("/", :payload => "</3").client_error?
  end

  test "building an Integrity::Project" do
    DataMapper.setup(:default, "sqlite3::memory:")
    DataMapper.auto_migrate!
    Bob.logger = Logger.new("/dev/null")
    Bob.directory = File.expand_path(File.dirname(__FILE__))
    Bobette.buildable = Bobette::Integrity::Project

    repo = GitRepo.new(:my_test_project)
    project = Integrity::Project.gen(:my_test_project, :uri => repo.path)
    repo.create
    repo.add_failing_commit

    commits = repo.commits.map { |c| {"id" => c[:identifier]} }
    post("/", :payload => { "ref" => "refs/heads",
                            "commits" => commits,
                            "repository" => { "url" => repo.path }}.to_json)
    assert_equal :failed, project.status

    FileUtils.rm_rf(repo.path)
  end
end
