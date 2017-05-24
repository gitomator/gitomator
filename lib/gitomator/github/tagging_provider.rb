require 'gitomator/github'
require 'gitomator/github/base_provider'


module Gitomator
  module GitHub
    class TaggingProvider < Gitomator::GitHub::BaseProvider


      # ---------------------- Static Factory Methods --------------------------

      #
      # @param config [Hash<String,Object>]
      # @return [Gitomator::GitHub::HostingProvider] GitHub hosting provider.
      #
      def self.from_config(config = {})
        return new(Gitomator::GitHub::github_client_from_config(config),
                   config['organization'])
      end

      #-------------------------------------------------------------------------


      def add_tags(repo, issue_or_pr_id, *tags)
        @gh.add_labels_to_an_issue(@repo_name_resolver.full_name(repo),
          issue_or_pr_id, tags
        ).map { |r| r.to_h }
      end

      def remove_tag(repo, id_or_name, tag)
        @gh.remove_label(@repo_name_resolver.full_name(repo), id_or_name, tag)
                .map { |r| r.to_h }  # Make the result a regular Ruby Hash
      end


      def tags(repo, id_or_name)
        repo = @repo_name_resolver.full_name(repo)
        @gh.labels_for_issue(repo, id_or_name).map {|r| r.name }
      end


      #
      # @return Enumerable of object identifiers.
      #
      def search(repo, label)
        if label.is_a? String
          q = "repo:#{@repo_name_resolver.full_name(repo)} type:issue|pr label:\"#{label}\""
          @gh.search_issues(q)
            .items.map {|item| item.number}  # Make the result an array of issue/or id's
        else
          raise "Unimplemented! Search only supports a single tag at the moment."
        end

      end


      def metadata(repo, tag=nil)
        repo = @repo_name_resolver.full_name(repo)

        if tag
          begin
            @gh.label(repo, tag).to_h   # Return metadata (Hash<Symbol,String>)
          rescue Octokit::NotFound
            return nil
          end
        else
          @gh.labels(repo).map {|r| [r.name, r.to_h]}.to_h  # Return Hash<String,Hash<Symbol,String>>, mapping tags to their metadata
        end
      end



      def set_metadata(repo, tag, metadata)
        repo = @repo_name_resolver.full_name(repo)
        color = metadata[:color] || metadata['color']
        raise "The only supported metadata property is 'color'" if color.nil?
        # TODO: Validate the color string (6-char-long Hex string. Any other formats supproted by GitHub?)

        if metadata(repo, tag).nil?
          @gh.add_label(repo, tag, color).to_h
        else
          @gh.update_label(repo, tag, {:color => color}).to_h
        end

      end


      def delete_metadata(repo, tag)
        @gh.delete_label!(@repo_name_resolver.full_name(repo), tag)
      end


    end
  end
end
