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
            role += " -- 提供下面指令 -- \n"
            role += "訂便當 - 開始訂便當\n"
            role += "取消便當 - 取消便當訂購\n"
            role += "查詢便當記錄 - 查詢便當訂購記錄\n"
            role += "查詢便當供餐車 - 查詢供餐車次及區間\n"
            role += "\n"
            role += "Created by Github: jiunjiun\n"
            role += "感謝：\n"
            role += "Howard Wu 提供 API - http://bentobox.goodideas-campus.com/"

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
