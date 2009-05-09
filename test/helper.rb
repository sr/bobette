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

class Bobette::TestCase < Test::Unit::TestCase
  include Rack::Test::Methods
  include TestHelper

  def app
    Bobette::App.new
  end

  def payload(commits, url, branch="master")
    { "ref"        => "refs/heads/#{branch}",
      "commits"    => commits.map { |c| { "id" => c[:identifier] } },
      "repository" => {"url" => url} }.to_json
  end
end

