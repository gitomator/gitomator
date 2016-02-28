module Gitomator
  module Model
    module Hosting
      class Repo

        attr_reader :name, :url, :opts

        def initialize(name, url, opts)
          @name = name
          @url = url
          @opts = opts
        end

      end
    end
  end
end
