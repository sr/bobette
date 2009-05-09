require "bob"
require "json"

require "forwardable"

module Bobette
  class << self
    attr_accessor :buildable
  end

  def call(env)
    request = Rack::Request.new(env)
    payload = JSON.parse(request.POST["payload"] || "")
    commits = payload["commits"].collect { |c| c["id"] }

    Bobette.buildable.new(payload).build(commits)

    Rack::Response.new("OK", 200).finish
  rescue JSON::JSONError
    Rack::Response.new("Unparsable payload", 400).finish
  end
  module_function :call
end
