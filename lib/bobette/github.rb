class Bobette
  class GitHub
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      payload = env["bobette.payload"]

      payload["kind"]   = "git"
      payload["uri"]    = uri(payload.delete("repository")["url"]).to_s
      payload["branch"] = payload.delete("ref").split("/").last
      env["bobette.payload"] = payload

      @app.call(env)
    end

    def uri(url)
      URI(url).tap { |u| u.scheme = "git" }
    end
  end
end
