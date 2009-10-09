module Bobette
  def self.new(builder)
    App.new(builder)
  end

  class App
    attr_reader :builder

    def initialize(builder)
      @builder = builder
    end

    def call(env)
      payload   = env["bobette.payload"]

      @builder.call(payload).each { |builder|
        builder.build if builder.respond_to?(:build)
      }

      [200, {"Content-Type" => "text/plain"}, ["OK"]]
    end
  end
end
