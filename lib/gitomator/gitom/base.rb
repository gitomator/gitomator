module Gitomator
  module Gitom

    class Base

      attr_reader :service, :provider, :action, :data

      def initialize(service, provider, action, data)
        @service = service
        @provider = provider
        @action = action
        @data = data
      end


      #
      # When replaying a Gitom, we need to make a method call (i.e. send a
      # message to some object). In order to do that, we need:
      # 1. The method/message, returned by the :action attr_reader.
      # 2. The arguments, returned by this method.
      #
      # @return Array
      #
      def replay_args()
        return [data]
      end

    end

  end
end
