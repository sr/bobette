module Bobette::TestHelper
  class BuilderStub < Bob::Test::BuilderStub
    class << self
      attr_accessor :no_buildable
    end

    def self.call(payload)
      return [] if no_buildable

      payload.delete("commits").collect { |c|
        new(payload.merge("command" => "./test", "commit" => c["id"]))
      }
    end

    def started(commit_info)
      Beacon.fire(:start, commit_info)
    end

    def completed(status, output)
      Beacon.fire(:finish, status, output)
    end
  end
end
