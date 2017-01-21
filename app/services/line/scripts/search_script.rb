module Line::Scripts
  module SearchScript

    def assign
      super

      return unless sourceable[:status] == Line::ScriptsBase::SourceableStatus::IDLE or sourceable[:status] == Line::ScriptsBase::SourceableStatus::SEARCH

      # --- parse info
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = event.message['text']

          if sourceable[:status] == Line::ScriptsBase::SourceableStatus::SEARCH
            sourceable_idle!

            opts = {
              date: message
            }

            begin
              msg = ''
              result = JSON.parse(TraBento.search(opts).body, symbolize_names: true)
              result[:result].each do |infos|
                infos.to_a.each do |info|
                  msg += "#{info.first}: #{info.last}\n"
                end
                msg += "\n"
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
          elsif message =~ /^(search|Search|查詢便當供餐車)$/
            sourceable_search!

            reply_messages = [
              {
                type: 'text',
                text: '請輸入 查詢日期 , 範例：2017/01/17'
              },
            ]
          end

          response = client.reply_message(event['replyToken'], reply_messages)
        end
      end
    end

  end
end
