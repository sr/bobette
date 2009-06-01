require File.dirname(__FILE__) + "/helper"

require "bobette/json"
require "bobette/github"

class BobetteGitHubTest < Bobette::TestCase
  def app
    @app ||= Rack::Builder.new {
      use Bobette::JSON do |env|
        Rack::Request.new(env).POST["payload"]
      end
      use Bobette::GitHub
      use Rack::Lint
      run lambda { |env|
        Rack::Response.new(env["bobette.payload"].to_json, 200).finish
      }
    }
  end

  def github_payload(repo, commits=[], branch="master")
    { "ref"        => "refs/heads/#{branch}",
      "commits"    => commits,
      "repository" => {"url" => "http://github.com/#{repo}"} }
  end

  def test_transform_payload
    commits = %w(b926de8 737bf26 8ba250e 78bb2de).map { |c| {"id" => c} }

    post("/", :payload => github_payload("integrity/bob", commits).to_json) { |response|
      assert response.ok?

      assert_equal(
        { "uri"     => "git://github.com/integrity/bob",
          "kind"    => "git",
          "branch"  => "master",
          "commits" => commits }, JSON.parse(response.body))
    }
  end
end
