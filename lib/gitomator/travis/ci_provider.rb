require 'gitomator/util/repo/name_resolver'
require 'travis'

module Gitomator
  module Travis
    class CIProvider


      # ---------------------- Static Factory Methods --------------------------

      class << self
        private :new
      end

      #
      # @param config [Hash<String,Object>]
      # @return [Gitomator::GitHub::HostingProvider] GitHub hosting provider.
      #
      def self.from_config(config = {})
        config = config.map {|k,v| [k.to_s, v] } .to_h

        if config['provider'] == 'travis'
          uri = ::Travis::Client::ORG_URI
        elsif config['provider'] == 'travis_pro'
          uri = ::Travis::Client::PRO_URI
        else
          raise "Invalid Travis CI provider name, #{config['provider']}."
        end

        if config['access_token']
          access_token = config['access_token']
        elsif config['github_access_token']
          access_token = ::Travis.github_auth(config['github_access_token'])
        else
          raise "Invalid Travis CI provider config - #{config}"
        end

        travis_client = ::Travis::Client.new({:uri => uri, :access_token => access_token })
        return new(travis_client, config['github_organization'])
      end


      # ------------------------------------------------------------------------


      #
      # @param travis_client [Travis::Client::Session]
      # @param github_organization [String] - Default GitHub organization
      #
      def initialize(travis_client, github_organization, opts={})
        raise "Travis client is nil" if travis_client.nil?
        @travis = travis_client
        @org = github_organization
        @repo_name_resolver = Gitomator::Util::Repo::NameResolver.new(@org)
      end

      def name
        :travis
      end


      def _find_repo_and_execute_block(repo)
        begin
          yield @travis.repo(@repo_name_resolver.full_name(repo))
        rescue ::Travis::Client::NotFound
          return nil
        end
      end


      def enable_ci(repo, opts={})
        _find_repo_and_execute_block(repo) {|r| r.enable}
      end

      def disable_ci(repo, opts={})
        _find_repo_and_execute_block(repo) {|r| r.disable}
      end

      def ci_enabled?(repo)
        _find_repo_and_execute_block(repo) {|r| r.reload.active? }
      end



      #
      # @param blocking [Boolean]
      #
      def sync(blocking=false, opts={})
        @travis.user.sync()
        while blocking && syncing?
          sleep(1)
        end
      end


      #
      # @return Boolean - Indicates whether a sync' is currently in progress.
      #
      def syncing?(opts={})
        @travis.user.reload.syncing?
      end





    end
  end
end
