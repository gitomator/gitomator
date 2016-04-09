
module Gitomator
  module Task
    class Base

      attr_reader :context

      #
      # @param context - An object that responds to :git, :hosting, :ci and :logger.
      #
      def initialize(context)
        @context = context
      end


      def logger
        context.logger
      end

      def git
        context.git
      end

      def hosting
        context.hosting
      end

      def ci
        context.ci
      end



      def run
        raise "Unimplemented"
      end

    end
  end
end
