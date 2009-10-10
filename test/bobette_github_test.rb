require File.dirname(__FILE__) + "/helper"

require "bobette/github"

class BobetteGitHubTest < Bobette::TestCase
  def app
    Rack::Builder.new {
      use Bobette::GitHub do
        $head
      end
      use Rack::Lint
      run lambda { |env|
        Rack::Response.new(env["bobette.payload"].to_json, 200).finish
      }
    }
  end

  def setup
    super
    $head = false
    @payload = File.read("test/helper/github_payload.js")
  end

  def test_transform_payload
    commits = JSON.parse(@payload)["commits"].collect {|c| c["id"]}

    post("/", :payload => @payload) { |response|
      assert response.ok?
      assert_equal(
        { "uri"     => "git://github.com/sr/bob",
          "scm"     => "git",
          "branch"  => "master",
          "commits" => commits }, JSON.parse(response.body))
    }
  end

  def test_transform_payload_private
    payload = JSON.parse(@payload)
    payload["repository"]["private"] = true

    post("/", :payload => payload.to_json) { |response|
      assert response.ok?
      assert_equal "git@github.com:sr/bob", JSON.parse(response.body)["uri"]
    }
  end

  def test_head_commit
    $head = true
    post("/", :payload => @payload) { |response|
      assert response.ok?
      assert_equal ["b2f5af7a7cd70e69d1145a6b4ddbf87df22bd343"],
        JSON.parse(response.body)["commits"]
    }
  end

  def test_invalid_payload
    assert post("/").client_error?
    assert post("/", {}, "bobette.payload" => "</3").client_error?
  end
end
