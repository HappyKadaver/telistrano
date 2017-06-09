require 'forwardable'
require_relative 'helpers'

module Telistrano
  module Messaging
    class Base

      include Helpers

      extend Forwardable
      def_delegators :env, :fetch

      def initialize(env: nil)
        @env = env
      end

      def payload_for_updating
        {
          text: "#{deployer} has started deploying branch #{branch} of #{application} to #{stage}"
        }
      end

      def payload_for_reverting
        {
          text: "#{deployer} has started rolling back branch #{branch} of #{application} to #{stage}"
        }
      end

      def payload_for_updated
        {
          text: "#{deployer} has finished deploying branch #{branch} of #{application} to #{stage}"
        }
      end

      def payload_for_reverted
        {
          text: "#{deployer} has finished rolling back branch of #{application} to #{stage}"
        }
      end

      def payload_for_failed
        {
          text: "#{deployer} has failed to #{deploying? ? 'deploy' : 'rollback'} branch #{branch} of #{application} to #{stage}"
        }
      end

      ################################################################################

      def payload_for(action)
        method = "payload_for_#{action}"
        respond_to?(method) && send(method)
      end
    end
  end
end

require_relative 'default'
require_relative 'deprecated'
require_relative 'null'
