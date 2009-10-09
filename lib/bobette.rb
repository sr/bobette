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
      @builder.call(env["bobette.payload"]).each { |b| b.build }
      [200, {"Content-Type" => "text/plain"}, ["OK"]]
    end
  end
end
