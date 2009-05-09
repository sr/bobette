require "integrity"

module Integrity
  class BuildableProject
    include Bob::Buildable

    extend Forwardable
    def_delegators :project, :branch, :command

    def initialize(payload)
      @payload = payload
    end

    def uri
      @uri ||= @payload["repository"]["url"]
    end

    def kind
      :git # TODO @kind ||= URI(uri).scheme.to_sym
    end

    alias_method :build_script, :command

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
