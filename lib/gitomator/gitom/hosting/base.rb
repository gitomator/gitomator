require 'gitomator/gitom/base'

module Gitomator
  module Gitom
    module Hosting
      class Base < Gitomator::Gitom::Base

        def initialize(provider, action, data)
          super(:hosting, provider, action, data)
        end

      end
    end
  end
end
