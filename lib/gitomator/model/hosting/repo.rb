module Gitomator
  module Model
    module Hosting
      class Repo

        attr_reader :name, :url, :opts

        def initialize(name, url, opts = {})
          @name = name
          @url = url
          @opts = opts
        end


        def inspect
          to_s
        end

        def to_s
          "<Repo at #{url}>"
        end

      end
    end
  end
end
