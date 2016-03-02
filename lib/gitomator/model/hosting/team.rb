module Gitomator
  module Model
    module Hosting
      class Team

        attr_reader :name, :opts

        def initialize(name, opts = {})
          @name = name
          @opts = opts
        end

      end
    end
  end
end
