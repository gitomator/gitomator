module Gitomator
  module Exception

    #
    # This error will be thrown when a valid service method is called, but
    # the underlying provider does not implement the given method.
    #
    class UnsupportedProviderMethod < StandardError
      attr_reader :provider, :method

      def initialize(provider, method)
        @provider = provider
        @method   = method

        provider_name = provider.respond_to?(:name) ? provider.name : 'Unknown'
        super("#{provider_name} provider does not support the #{method} method.")
      end
    end

  end
end
