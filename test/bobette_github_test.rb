require "helper"
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
    commits = JSON.parse(@payload)["commits"]

    post("/", :payload => @payload) { |response|
      payload = JSON.parse(response.body)

      assert response.ok?

      assert_equal "git",                     payload["scm"]
      assert_equal "git://github.com/sr/bob", payload["uri"]
      assert_equal "master",                  payload["branch"]
      assert_equal 2,                         payload["commits"].size

      commit = payload["commits"].first

      assert_equal "c6dd001c1a95763b2ea62201b73005a6b86c048e", commit["id"]
      assert_match /instead of private #path method/, commit["message"]
      assert_equal "2009-09-30T06:10:44-07:00", commit["timestamp"]
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
      payload = JSON.parse(response.body)

      assert response.ok?
      assert_equal 1, payload["commits"].size

      commit = payload["commits"].first

      assert_equal "b2f5af7a7cd70e69d1145a6b4ddbf87df22bd343", commit["id"]
      assert_equal "Add rip files",             commit["message"]
      assert_equal "2009-09-30T06:16:12-07:00", commit["timestamp"]
    }
  end

  def test_invalid_payload
    assert post("/").client_error?
    assert post("/", {}, "bobette.payload" => "</3").client_error?
  end
end
