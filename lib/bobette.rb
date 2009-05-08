require "sinatra/base"
require "bob"
require "json"

require "forwardable"

module Bobette
  class << self
    attr_accessor :buildable
  end

  class App < Sinatra::Base
    post "/" do
      # TODO: require a buildable to implement `#commits`?
      buildable = Bobette.buildable.new(payload)

      Bob.build(buildable, payload["commits"].map { |c| c["id"] })
    end

    def payload
      JSON.parse(request.POST["payload"] || "")
    rescue JSON::JSONError
      halt 400
    end
  end
end
