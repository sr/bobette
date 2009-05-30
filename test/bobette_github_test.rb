require File.dirname(__FILE__) + "/helper"
require "bobette/github"

class BobetteGitHubTest < Bobette::TestCase
  def app
    @app ||= Rack::Builder.new {
      use Bobette::GitHub
      # TODO use Rack::Lint
      run Bobette.new(BuildableStub)
    }
  end

  def payload(repo, branch="master")
    { "ref"   => "refs/heads/#{branch}",
      "commits" => repo.commits.map { |c| {"id" => c[:identifier]} },
      "repository" => {"url" => repo.path} }
  end

  def test_send_correct_payload
    assert post("/", payload(@repo).to_json).ok?

    assert_equal 4, @metadata.count
    assert_equal 4, @builds.count

    commit = @repo.head

    assert_equal :failed, @builds[commit].first
    assert_equal "Running tests...\n", @builds[commit].last
    assert_equal "This commit will fail", @metadata[commit][:message]
  end
end
