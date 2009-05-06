require "sinatra/base"
require "bob"
require "json"

module Bobette
  class << self
    attr_accessor :buildable
  end

  class App < Sinatra::Base
    post "/" do
      # TODO: Buildable should implement #commits too?
      # TODO: Also, why not use an Hash instead?
      buildable = Bobette.buildable.new(payload)

      Bob.build(buildable, payload["commits"])
    end

    def payload
      JSON.parse(request.POST["payload"])
    end
  end
end
