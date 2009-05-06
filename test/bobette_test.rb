require File.dirname(__FILE__) + "/test_helper"

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
    stub(Bob).build(@buildable, payload["commits"]) { nil }

    post("/", :payload => payload.to_json) { |r| assert r.ok? }
  end
end
