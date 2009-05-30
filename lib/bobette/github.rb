class Bobette
  class GitHub
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      body = ""; env["rack.input"].each { |c| body << c }
      payload = JSON.parse(body)

      payload["uri"]    = uri(payload["repository"].delete("url"))
      payload["branch"] = payload.delete("ref").split("/").last
      env["rack.input"] = [payload.to_json]

      @app.call(env)
    rescue JSON::JSONError
      Rack::Response.new("Unparsable payload", 400).finish
    end

    def uri(url)
      URI(url).tap { |u| u.scheme = "git" }
    end
  end
end
