require 'gitomator/service/base'

module Gitomator
  module Service
    module Tagging
      class Service < Gitomator::Service::Base





        #
        # Add `tag` to object (the object with the given `id_or_name` in the
        # given `namespace`)
        #
        # @param namespace  [String]
        # @param id_or_name [String/Number]
        # @param tags [*String]
        #
        def add_tags(namespace, id_or_name, *tags)
          _delegate(__callee__, namespace, id_or_name, *tags)
        end

        #
        # Remove tag from object.
        #
        # @param namespace  [String]
        # @param id_or_name [String/Number]
        # @param tag [String]
        #
        def remove_tag(namespace, id_or_name, tag)
          _delegate(__callee__, namespace, id_or_name, tag)
        end

        #
        # Get all tags associated with the specified object.
        #
        # @param namespace  [String]
        # @param id_or_name [String/Number]
        #
        # @return [Array<String>]
        #
        def tags(namespace, id_or_name)
          _delegate(__callee__, namespace, id_or_name)
        end


        #
        # Search for objects by tag(s).
        #
        # @param namespace  [String]
        # @param query [String/Hash] - Either a single tag (String) or a query (Hash).
        #
        # @return Enumerable of object identifiers.
        #
        def search(namespace, query)
          _delegate(__callee__, namespace, query)
        end

        #
        # Get the metadata associated with the given tag in the given namespace.
        # If a `tag` is not specified, get metadata for all tags in the namespace.
        #
        # @param namespace  [String]
        # @param tag  [String]
        #
        # @return [Hash<String,Object>] The tag's metadata. If no tag was specified, return a Hash that maps each tag to its metadata.
        #
        def metadata(namespace, tag=nil)
          _delegate(__callee__, namespace, tag)
        end

        #
        # Add the given metadata to the given tag (in the given namespace).
        # You can remove metadata properties by updating their value to nil.
        #
        # @param namespace  [String]
        # @param tag  [String]
        # @param metadata  [String]
        #
        def set_metadata(namespace, tag, metadata)
          _delegate(__callee__, namespace, tag, metadata)
        end

        #
        # Delete all metadata associated with the given tag (in the given namespace).
        #
        # @param namespace  [String]
        # @param tag  [String]
        #
        def delete_metadata(namespace, tag)
          _delegate(__callee__, namespace, tag)
        end

      end
    end
  end
end
