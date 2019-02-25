# frozen_string_literal: true

require_relative 'lib/telegram/bot/gem_finder'

token = ARGV[0]
raise 'Please provide bot token' unless token

Telegram::Bot::GemFinder.run(token, logger: Logger.new($stdout))
