require "test/unit"
require "contest"
require "rr"
require "rack/test"

require File.dirname(__FILE__) + "/../lib/bobette"

class FakeBuildable
  def initialize(payload); end

  def uri
    "git://github.com/foo/bar.git"
  end

  def branch
    "master"
  end

  def kind
    :git
  end
end

class BobetteTest < Test::Unit::TestCase
  class << self
    alias_method :it, :test
  end

  include RR::Adapters::TestUnit
  include Rack::Test::Methods

  def app
    Bobette::App.tap { |app| app.set(:environment, :test) }
  end

  def payload
    { "ref"        => "ref",
      "commits"    => [{"id" => "commit.id"}],
      "repository" => {"url" => "http://repo_url"} }
  end

  setup do
    Bobette.buildable = FakeBuildable

    @buildable = FakeBuildable.new(payload)
  end

  it "makes a buildable from the payload and builds it with Bob" do
    stub(FakeBuildable).new(payload) { @buildable }
    stub(Bob).build(@buildable, payload["commits"]) { nil }

    post("/", :payload => payload.to_json) { |r| assert r.ok? }
  end
end
