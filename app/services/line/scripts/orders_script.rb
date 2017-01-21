module Line::Scripts
  module OrdersScript

    module Step
      ID_NUMBER          = 1
      RESERVATION_NUMBER = 2
    end

    def assign
      super

      return unless sourceable[:status] == Line::ScriptsBase::SourceableStatus::IDLE or sourceable[:status] == Line::ScriptsBase::SourceableStatus::ORDERS

      # --- parse info
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = event.message['text']

          Rails.logger.debug { " -- sourceable status: #{sourceable[:status]}" }

          if sourceable[:status] == Line::ScriptsBase::SourceableStatus::ORDERS
            case sourceable[:orders][:step]
            when Step::ID_NUMBER
              @sourceable[:orders][:params][:id] = message
              @sourceable[:orders][:step] = Step::RESERVATION_NUMBER
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入 預約號:"
                },
              ]
            when Step::RESERVATION_NUMBER
              sourceable_idle!

              @sourceable[:orders][:params][:resNo] = message
              params = sourceable[:orders][:params]

              response = TraBento.query params
              begin
                result = JSON.parse(response.body, symbolize_names: true)[:result]
                msg = ''
                result.to_a.each do |info|
                  msg += "#{info.first}: #{info.last}\n"
                end

                result = msg
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
          elsif message =~ /^(orders|Orders|查詢便當記錄)$/
            sourceable_orders!

            reply_messages = [
              {
                type: 'text',
                text: "查詢便當訂購記錄"
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
