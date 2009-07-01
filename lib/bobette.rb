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
      payload   = env["bobette.payload"]
      commits   = payload["commits"].collect { |c| c["id"] }
      buildable = @buildable.call(payload)

      if buildable.respond_to?(:build)
        buildable.build(commits)
        [200, {"Content-Type" => "text/plain"}, ["OK"]]
      else
        [412, {"Content-Type" => "text/plain"}, ["Precondition Failed"]]
      end
    end
  end
end
