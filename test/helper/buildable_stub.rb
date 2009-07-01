module TestHelper
  class BuildableStub < Bob::Test::BuildableStub
    def self.call(payload)
      kind         = payload["kind"]
      uri          = payload["uri"]
      branch       = payload["branch"]
      build_script = "./test"

      new(kind, uri, branch, build_script)
    end

    def start_building(commit_id, commit_info)
      Beacon.fire(:start, commit_id, commit_info)
    end

    def finish_building(commit_id, status, output)
      Beacon.fire(:finish, commit_id, status, output)
    end
  end
end
