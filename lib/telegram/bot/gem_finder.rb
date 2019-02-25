# frozen_string_literal: true

require 'telegram/bot'
require_relative '../../../lib/api/ruby_gems_api'

module Telegram
  module Bot
    class GemFinder < Telegram::Bot::Client
      attr_accessor :bot

      def handle_message(message)
        command = message.text.downcase.split(' ')
        if command.empty?
          @bot.api.send_message(chat_id: message.chat.id, text: 'Say again')
        elsif command[0] == '/start' || command[0] == '/help'
          @bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Бот умеет искать гемы по их названию, просто введите название гема, например: <code>devise</code>
Чтобы узнать информацию о версиях гема наберите: <pre>versions devise</pre>',
            parse_mode: 'HTML')
        elsif !command[0].empty?
          if command.size == 1
            res = RubyGemsApi.new('find_gem', command[0])
            send_html_message(message.chat.id, res.text)
          elsif command[0] == 'versions' && command.size >= 2
            res = RubyGemsApi.new('versions', command[1])
            send_html_message(message.chat.id, res.text)
          else
            @bot.api.send_message(chat_id: message.chat.id, text: 'Unknown command')
          end
        else
          @bot.api.send_message(chat_id: message.chat.id, text: 'Unknown command')
        end
      end

      def send_html_message(chat_id, message)
        @bot.api.send_message(chat_id: chat_id, text: message, parse_mode: 'HTML')
      end

      def run
        super do |bot|
          @bot = bot
          @bot.listen do |message|
            Thread.start(message) do |msg|
              begin
                handle_message(msg)
              rescue RuntimeError => e
                @bot.api.send_message(chat_id: msg.chat.id, text: 'Internal error. Please contact the admin')
                @bot.logger.error(e)
              end
            end
          end
        end
      end
    end
  end
end
