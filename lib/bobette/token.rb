module Bobette
  class Token
    def initialize(app, &authorizer)
      @app        = app
      @authorizer = authorizer
    end

    def call(env)
      if @authorizer.call(env["PATH_INFO"][1..-1])
        @app.call(env)
      else
        Rack::Response.new("Invalid token", 403).finish
      end
    end
  end
end
