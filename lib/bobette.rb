require "sinatra/base"
require "integrity"
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

  module Integrity
    class Project
      extend Forwardable
      def_delegators :project, :branch, :command

      alias_method :build_script, :command

      def initialize(payload)
        @payload = payload
      end

      def uri
        @uri ||= @payload["repository"]["url"]
      end

      def kind
        :git # TODO @kind ||= URI(uri).scheme.to_sym
      end

      def start_building(commit_id, commit_info)
        @commit = project.commits.new(commit_info.merge(:identifier => commit_id))
        @build  = ::Integrity::Build.new(:started_at => Time.now)
        @commit.update_attributes(:build => @build)
      end

      def finish_building(commit_id, status, output)
        @build.update_attributes(
          :successful => status, :output => output,
          :completed_at => Time.now)
      end

      private
        def project
          @project ||= ::Integrity::Project.first(:uri => uri)
        end
    end
  end
end
