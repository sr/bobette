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
      :git
    end

    alias_method :build_script, :command

    def start_building(commit_id, commit_info)
      return unless watch_branch?

      @commit = project.commits.new(commit_info.merge(:identifier => commit_id))
      @build  = ::Integrity::Build.new(:started_at => Time.now)
      @commit.update_attributes(:build => @build)
    end

    def finish_building(commit_id, status, output)
      @build.update_attributes(
        :successful => status, :output => output,
        :completed_at => Time.now) if @build
    end

    private
      def project
        @project ||= ::Integrity::Project.first(:uri => uri)
      end

      def watch_branch?
        @payload["ref"].split("/").last == branch
      end
  end
end
