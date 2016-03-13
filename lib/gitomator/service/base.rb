gem 'logger'; require 'logger'

module Gitomator
  module Service
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
        @before_callbacks.each {|block| block.call(method, args) }

        begin
          result = @provider.send(method, *args)
        rescue Exception => e
          @error_callbacks.each {|block| block.call(method, args, e) }
          raise e
        end

        @after_callbacks.each {|block| block.call(method, args, result) }
        return result
      end

    end
  end
end
