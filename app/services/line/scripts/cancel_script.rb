module Line::Scripts
  module CancelScript

    module Step
      ID_NUMBER          = 1
      RESERVATION_NUMBER = 2
    end

    def assign
      super

      return unless sourceable[:status] == Line::ScriptsBase::SourceableStatus::IDLE or sourceable[:status] == Line::ScriptsBase::SourceableStatus::CANCEL

      # --- parse info
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = event.message['text']

          if sourceable[:status] == Line::ScriptsBase::SourceableStatus::CANCEL
            case sourceable[:cancel][:step]
            when Step::ID_NUMBER
              @sourceable[:cancel][:params][:id] = message
              @sourceable[:cancel][:step] = Step::RESERVATION_NUMBER
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入 預約號:"
                },
              ]
            when Step::RESERVATION_NUMBER
              sourceable_idle!

              @sourceable[:cancel][:params][:resNo] = message
              params = sourceable[:cancel][:params]

              response = TraBento.cancel params
              begin
                result = JSON.parse(response.body, symbolize_names: true)[:result]
              rescue Exception => e
                result = '系統錯誤!'
              end

              reply_messages = [
                {
                  type: 'text',
                  text: result
                },
              ]
            end
          elsif message =~ /^(cancel|Cancel|取消便當訂購)$/
            sourceable_cancel!

            reply_messages = [
              {
                type: 'text',
                text: "取消便當"
              },
              {
                type: 'text',
                text: "請輸入 身份證:"
              }
            ]
          end

          response = client.reply_message(event['replyToken'], reply_messages)
        end
      end
    end

  end
end
