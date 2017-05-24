module Gitomator
  module GitHub
    module Model
      class HostedRepo

        @@default_protocol = :https

        def self.default_protocol
          @@default_protocol
        end

        def self.default_protocol=protocol
          protocol = protocol.to_sym
          raise "Invalid protocol #{protocol}" unless [:https, :ssh].include? protocol
          @@default_protocol = protocol
        end


        #-----------------------------------------------------------------------


        #
        # @param gh_repo [Sawyer::Resource]
        #
        def initialize(gh_repo)
          @r = gh_repo
        end


        def name
          @r.name
        end

        def full_name
          @r.full_name
        end

        def url(protocol=nil)
          protocol ||= HostedRepo::default_protocol()
          if protocol.to_sym == :ssh
            return @r.ssh_url
          else
            return @r.clone_url
          end
        end

        def properties
          return {
            :description    => @r.description,
            :homepage       => @r.homepage,
            :private        => @r.private?,
            :has_issues     => @r.has_issues?,
            :has_wiki       => @r.has_wiki?,
            :has_downloads  => @r.has_downloads?,
            :default_branch => @r.default_branch
          }
        end


      end
    end
  end
end
