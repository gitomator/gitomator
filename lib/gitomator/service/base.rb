gem 'logger'; require 'logger'

module Gitomator
  module Service
    class Base

      attr_reader :provider

      def initialize(provider, opts = {})
        @provider = provider
        @logger = opts[:logger] || Logger.new(STDOUT)
      end


      def _delegate(method, *args)
        result = nil
        start = Time.now
        begin
          result = @provider.send(method, *args)
          _log(method, args, start, {result: result})
          return result
        rescue Exception => e
          _log(method, args, start, {exception: e})
          raise
        end
      end

      def _log(method, args, start, data)
        @logger.debug(
          {provider: (provider.respond_to?(:name) ? provider.name : provider),
           method: method, args: args,
          duration_ms: ((Time.now. - start) * 1000),
         }.merge(data)
        )
      end


    end
  end
end
