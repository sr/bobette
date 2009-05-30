require "bob"
require "json"

class Bobette
  attr_accessor :buildable

  def initialize(buildable)
    @buildable = buildable
  end

  def call(env)
    request = Rack::Request.new(env)
    payload = JSON.parse(request.POST["payload"] || "")
    commits = payload["commits"].collect { |c| c["id"] }

    action = Proc.new { @buildable.new(payload).build(commits) }

    (Object.const_defined?(:EM) && EM.reactor_running?) ?
      EM.defer(action) : action.call

    Rack::Response.new("OK", 200).finish
  rescue JSON::JSONError
    Rack::Response.new("Unparsable payload", 400).finish
  end
end
