require "bob"

module Bobette
  def self.new(buildable)
    App.new(buildable)
  end

  class App
    attr_accessor :buildable

    def initialize(buildable)
      @buildable = buildable
    end

    def call(env)
      payload = env["bobette.payload"]
      commits = payload["commits"].collect { |c| c["id"] }

      action = Proc.new { @buildable.new(payload).build(commits) }

      (Object.const_defined?(:EM) && EM.reactor_running?) ?
        EM.defer(action) : action.call

      Rack::Response.new("OK", 200).finish
    end
  end
end
