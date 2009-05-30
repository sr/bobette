require "json"

class Bobette
  class JSON
    def initialize(app)
      @app = app
    end

    def call(env)
      body = ""; env["rack.input"].each { |c| body << c }
      env["bobette.payload"] = ::JSON.parse(body)

      @app.call(env)
    rescue ::JSON::JSONError
      Rack::Response.new("Unparsable payload", 400).finish
    end
  end
end
