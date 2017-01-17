module Line::Scripts
  module SearchScript

    def assign
      super

      return unless sourceable[:status] == Line::ScriptsBase::SourceableStatus::IDLE or sourceable[:status] == Line::ScriptsBase::SourceableStatus::SEARCH

      # --- parse info
      case event
      when Line::Bot::Event::Message
        message_id = event.message['id']
        case event.type
        when Line::Bot::Event::MessageType::text
          message = event.message['text']

          if sourceable[:status] == Line::ScriptsBase::SourceableStatus::SEARCH
            opts = {
              date: message
            }

            begin
              msg = ''
              result = JSON.parse(TraBento.search(opts).body, symbolize_names: true)
              result.each do |info|
                info = info.to_a
                msg += "#{info.first}: #{info.last}"
              end
            rescue => e
              msg = 'Error!'
            end

            reply_messages = [
              {
                type: 'text',
                text: msg
              },
            ]
          elsif message =~ /^(search|Search|查詢供餐車次及區間)/
            sourceable[:status] = Line::ScriptsBase::SourceableStatus::SEARCH
            save_sourceable!

            reply_messages = [
              {
                type: 'text',
                text: '請輸入查詢日期，範例：2017/01/17'
              },
            ]
          end

          response = client.reply_message(event['replyToken'], reply_messages)
        end
      end
    end

  end
end
