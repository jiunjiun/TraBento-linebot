module Line::Scripts
  module HelpScript

    def assign
      super

      # --- parse info
      case event
      when Line::Bot::Event::Message
        message_id = event.message['id']
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = event.message['text']

          if message =~ /^(help|HELP|Help)/
            role  = ''
            role += "help - help\n"

            reply_messages = [
              {
                type: 'text',
                text: role
              },
              {
                type: 'sticker',
                packageId: '2',
                stickerId: '144',
              }
            ]
            response = client.reply_message(event['replyToken'], reply_messages)
          end
        end
      end
    end

  end
end
