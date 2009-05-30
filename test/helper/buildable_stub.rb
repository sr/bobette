module TestHelper
  class BuildableStub
    include Bob::Buildable

    attr_accessor :kind, :uri, :branch, :build_script

    def initialize(payload)
      @kind = :git
      @uri  = payload["uri"]
      @branch = payload["branch"]
      @build_script = "./test"

      @metadata = {}
      @builds   = {}
    end

    def start_building(commit_id, commit_info)
      Beacon.fire(:start, commit_id, commit_info)
    end

    def finish_building(commit_id, status, output)
      Beacon.fire(:finish, commit_id, status, output)
    end
  end
end
