module TestHelper
  class BuildableStub < Bob::Test::BuildableStub
    class << self
      attr_accessor :no_buildable
    end

    def self.call(payload)
      return nil if no_buildable

      scm          = payload["scm"]
      uri          = payload["uri"]
      branch       = payload["branch"]
      build_script = "./test"

      new(scm, uri, branch, build_script)
    end

    def start_building(commit_id, commit_info)
      Beacon.fire(:start, commit_id, commit_info)
    end

    def finish_building(commit_id, status, output)
      Beacon.fire(:finish, commit_id, status, output)
    end
  end
end
