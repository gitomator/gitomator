require 'trollop'
require 'gitomator/version'


module Gitomator
    module ScriptUtil

      DEFAULT_CONTEXT_ENV_VAR_NAME = 'GITOMATOR_CONTEXT'

      def self.default_context_file
        return ENV[DEFAULT_CONTEXT_ENV_VAR_NAME] || File.expand_path('~/.gitomator')
      end

      #---------------------------------------------------------------------------

      class DefaultOptionParser < Trollop::Parser

        def initialize(help_text)
          super()
          banner "#{help_text}\nOptions:"
          version "Gitomator #{Gitomator::VERSION} (c) 2016 Joey Freund"

          context_description = "YAML configuration for various service providers (e.g. GitHub hosting, or Travis CI)."
          unless ENV[DEFAULT_CONTEXT_ENV_VAR_NAME]
            context_description += "\nYou can override the default configuration file by setting the #{DEFAULT_CONTEXT_ENV_VAR_NAME} environment variable."
          end

          opt :context,
                context_description ,
                :type => :string,
                :default => ScriptUtil::default_context_file
        end


        def parse(args)
          return { :context => ScriptUtil::default_context_file }.merge(
            Trollop::with_standard_exception_handling(self) { super(args)  }
          )
        end

      end

      #---------------------------------------------------------------------------

      #
      # @param task [Gitomator::Task::*] An object with a run() method.
      #
      def self.run_task(task)
        begin
          task.run
        rescue => e
          abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
        end
      end

      #
      # @param tasks [Array<Gitomator::Task::*>]
      #
      def self.run_tasks(tasks)
        begin
          tasks.each { |task| task.run }
        rescue => e
          abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
        end
      end


    end
end
