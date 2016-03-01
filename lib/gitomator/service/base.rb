gem 'logger'; require 'logger'

module Gitomator
  module Service
    class Base


      def initialize(provider, opts = {})
        @provider = provider
        @logger = opts[:logger] || Logger.new(STDOUT)
      end


      def _delegate(method, *args)
        result = nil
        start = Time.now
        begin
          result = @provider.send(method, *args)
          @logger.debug({method: method, args: args, result: result, start: start, finish: Time.now})
          return result
        rescue Exception => e
          @logger.debug({method: method, args: args, exception: e, start: start, finish: Time.now})
          raise
        end
      end


    end
  end
end
