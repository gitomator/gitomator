gem 'logger'; require 'logger'

module Gitomator
  module Service


    #
    # Custom exception class.
    # Allows us to distinguish between the following two cases:
    # 1. Calling a valid service method that is not implemented by a specific provider.
    # 2. Calling an invalid service method.
    #
    # The first case should result in a NotSupportedByProvider, and in the
    # second case should result in the usual NoSuchMethodError.
    #
    class NotSupportedByProvider < StandardError
      attr_reader :provider, :method

      def initialize(provider, method)
        @provider = provider
        @method   = method

        provider_name = provider.respond_to?(:name) ? provider.name : 'Unknown'
        super("#{provider_name} provider does not support the #{method} method.")
      end
    end



    class Base

      attr_reader :provider

      def initialize(provider, opts = {})
        @provider = provider
        @logger = opts[:logger] || Logger.new(STDOUT)

        @before_callbacks = []
        @after_callbacks = []
        @error_callbacks = []
      end

      #
      # @param type (Symbol) One of :before, :after: or :error.
      #
      def inject_callback(type, &block)
        case type
        when :before
          @before_callbacks.push block
        when :after
          @after_callbacks.push block
        when :error
          @error_callbacks.push block
        else
          raise "Invalid callback type, #{type}. Must be one of :before, :after or :error."
        end
      end


      def _delegate(method, *args)
        result = nil
        @before_callbacks.each {|block| self.instance_exec(method, args, &block) }

        begin
          if provider.respond_to?(method)
            result = @provider.send(method, *args)
          else
            raise NotSupportedByProvider.new(@provider, method)
          end
        rescue Exception => e
          @error_callbacks.each {|block| self.instance_exec(method, args, e, &block) }
          raise e
        end

        @after_callbacks.each {|block| self.instance_exec(method, args, result, &block) }
        return result
      end

    end
  end
end
