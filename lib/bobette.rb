require "bob"

module Bobette
  def self.new(buildable)
    App.new(buildable)
  end

  class App
    attr_reader :buildable

    def initialize(buildable)
      @buildable = buildable
    end

    def call(env)
      payload = env["bobette.payload"]
      commits = payload["commits"].collect { |c| c["id"] }
      @buildable.call(payload).build(commits)

      Rack::Response.new("OK", 200).finish
    end
  end
end
