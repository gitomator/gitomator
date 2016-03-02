module Gitomator
  module Model
    module Hosting
      class Team

        attr_reader :id, :name, :opts

        def initialize(id, name, opts = {})
          @id   = id
          @name = name
          @opts = opts
        end


        def inspect
          to_s
        end

        def to_s
          "<Team[#{id}]: #{name}>"
        end

      end
    end
  end
end
