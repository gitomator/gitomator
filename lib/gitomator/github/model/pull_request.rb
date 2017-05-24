require 'gitomator/github/model/hosted_repo'

module Gitomator
  module GitHub
    module Model
      class PullRequest


        #
        # @param gh_pull_request [Sawyer::Resource]
        # @param octokit [Octokit::Client]
        #
        def initialize(gh_pull_request, octokit)
          @r = gh_pull_request
          @octokit = octokit
        end


        def id
          @r.number
        end

        def title
          @r.title
        end

        def created_by
          @r.user.login
        end

        def created_at
          @r.created_at
        end

        # @return [String] One of 'open', 'close'
        #
        def state
          @r.state
        end

        #
        # @return true/false/nil
        #
        def mergeable?
          # In Octokit, the two methods `pull_request` and `pull_requests` return
          # different type of objects (the one returned by `pull_requests` is missing
          # the mergeable? method)
          if (not @r.respond_to? :mergeable?)
            @r = @octokit.pull_request(@r.base.repo.full_name, @r.number)
          end

          if @r.mergeable_state == 'clean'
            return @r.mergeable?
          else
            return nil
          end
        end

        # The "source repo"
        def head_repo
          Gitomator::GitHub::Model::HostedRepo.new(@r.head.repo)
        end

        def head_branch
          @r.head.label.split(':').last
        end

        # The "destination repo"
        def base_repo
          Gitomator::GitHub::Model::HostedRepo.new(@r.base.repo)
        end

        def base_branch
          @r.base.label.split(':').last
        end


      end
    end
  end
end
