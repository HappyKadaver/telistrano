require_relative 'messaging/base'
require 'net/http'
require 'json'
require 'forwardable'

load File.expand_path("../tasks/slack.rake", __FILE__)

module Telistrano
  class Capistrano

    attr_reader :backend
    private :backend

    extend Forwardable
    def_delegators :env, :fetch, :run_locally

    def initialize(env)
      @env = env
      config = fetch(:telistrano, {})
      @chat_ids = config.chat_ids
      @api_token = config.api_token
    end

    def run(action)
      _self = self
      run_locally { _self.process(action, self) }
    end

    def process(action, backend)
      @backend = backend

      payload = @messaging.payload_for(action)
      return if payload.nil?

      payload = {
        username: @messaging.username,
        icon_url: @messaging.icon_url,
        icon_emoji: @messaging.icon_emoji,
      }.merge(payload)

      channels = Array(@messaging.channels_for(action))
      if !@messaging.via_slackbot? == false && channels.empty?
        channels = [nil] # default webhook channel
      end

      channels.each do |channel|
        post(payload.merge(channel: channel))
      end
    end

    private ##################################################

    def post(payload)

      if dry_run?
        post_dry_run(payload)
        return
      end

      begin
        response = post_to_telegram(payload)
      rescue => e
        backend.warn("[slackistrano] Error notifying Slack!")
        backend.warn("[slackistrano]   Error: #{e.inspect}")
      end

      if response && response.code !~ /^2/
        warn("[slackistrano] Slack API Failure!")
        warn("[slackistrano]   URI: #{response.uri}")
        warn("[slackistrano]   Code: #{response.code}")
        warn("[slackistrano]   Message: #{response.message}")
        warn("[slackistrano]   Body: #{response.body}") if response.message != response.body && response.body !~ /<html/
      end
    end

    def post_to_telegram(payload)
      Telegram::Bot::Client.run(@api_token) do |bot|
        @chat_ids.each do |chat_id|
          bot.api.send_message(chat_id: chat_id, text: payload)
        end
      end
    end

    def dry_run?
      ::Capistrano::Configuration.env.dry_run?
    end

    def post_dry_run(payload)
        backend.info("[slackistrano] Slackistrano Dry Run:")
      if @messaging.via_slackbot?
        backend.info("[slackistrano]   Team: #{@messaging.team}")
        backend.info("[slackistrano]   Token: #{@messaging.token}")
      else
        backend.info("[slackistrano]   Webhook: #{@messaging.webhook}")
      end
        backend.info("[slackistrano]   Payload: #{payload.to_json}")
    end

  end
end
