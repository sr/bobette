require "json"

module Bobette
  class GitHub
    attr_accessor :head

    def initialize(app, &block)
      @app  = app
      @head = false

      yield self if block_given?
    end

    def call(env)
      payload = Rack::Request.new(env).POST["payload"] || ""
      payload = JSON.parse(payload)
      payload["kind"]   = "git"
      payload["uri"]    = uri(payload.delete("repository")["url"]).to_s
      payload["branch"] = payload.delete("ref").split("/").last
      if (head = payload.delete("after")) && @head
        payload["commits"] = [{"id" => head}]
      end
      env["bobette.payload"] = payload

      @app.call(env)
    rescue JSON::JSONError
      Rack::Response.new("Unparsable payload", 400).finish
    end

    def uri(url)
      URI(url).tap { |u| u.scheme = "git" }
    end
  end
end
