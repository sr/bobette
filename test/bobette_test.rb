require "helper"

class BobetteTest < Bobette::TestCase
  def app
    @app ||= Rack::Builder.new {
      use Rack::Lint
      run Bobette.new(BuilderStub)
    }
  end

  def payload(repo)
    { "branch"  => repo.branch,
      "commits" => repo.commits,
      "uri"     => repo.uri.to_s,
      "scm"     => repo.scm }
  end

  def setup
    super

    @repo = GitRepo.new("my_test_project")
    @repo.create
    3.times{|i|i.odd? ? @repo.add_successful_commit : @repo.add_failing_commit}

    @commits = {}
    @builds  = {}

    Beacon.watch(:start) { |commit|
      @id = commit["id"]
      @commits[@id] = commit
    }

    Beacon.watch(:finish) { |status, output|
      @builds[@id] = [status ? :successful : :failed, output]
    }
  end

  def test_valid_payload
    assert post("/", {}, "bobette.payload" => payload(@repo)).ok?

    assert_equal 4, @builds.count
    assert_equal 4, @commits.count

    commit = @repo.head

    assert_equal :failed, @builds[commit].first
    assert_equal "Running tests...\n", @builds[commit].last
    assert_equal "This commit will fail", @commits[commit]["message"]
    assert_equal "John Doe <johndoe@example.org>", @commits[commit]["author"]
    assert_kind_of Time, @commits[commit]["timestamp"]
  end

  def test_invalid_payload
    assert_raise(NoMethodError) { assert post("/") }
    assert_raise(NoMethodError) { post("/", {}, "bobette.payload" => "</3") }
  end

  def test_no_buildable
    BuilderStub.no_buildable = true
    payload = payload(@repo).update("branch" => "unknown")
    post("/", {}, "bobette.payload" => payload) { |r| r.ok? }
  end
end
