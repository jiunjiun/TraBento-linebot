module Line::Scripts
  module OrderScript

    module Step
      ID_NUMBER          = 1
      RESERVATION_NUMBER = 2
      RIBS_BOX           = 3
      VEGETARIAN_BOX     = 4
      VAT_NUMBER         = 5
      CAPTCHA            = 6
      CONFIRM            = 7
    end

    def assign
      super

      return unless sourceable[:status] == Line::ScriptsBase::SourceableStatus::IDLE or sourceable[:status] == Line::ScriptsBase::SourceableStatus::ORDER

      # --- parse info
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = event.message['text']

          if sourceable[:status] == Line::ScriptsBase::SourceableStatus::ORDER
            case sourceable[:order][:step]
            when Step::ID_NUMBER
              @sourceable[:order][:params][:id] = message
              @sourceable[:order][:step] = Step::RESERVATION_NUMBER
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入 預約號:"
                },
              ]
            when Step::RESERVATION_NUMBER
              @sourceable[:order][:params][:resNo] = message
              @sourceable[:order][:step] = Step::RIBS_BOX
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入 排骨便當(80元) 數量(數量0-6之間):"
                },
              ]
            when Step::RIBS_BOX
              @sourceable[:order][:params][:ribsBox] = message.to_i
              @sourceable[:order][:step] = Step::VEGETARIAN_BOX
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入 素食便當(80元) 數量(數量0-6之間):"
                },
              ]
            when Step::VEGETARIAN_BOX
              @sourceable[:order][:params][:vegetarianBox] = message.to_i
              @sourceable[:order][:step] = Step::VAT_NUMBER
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入 統一編號(選填):\n若沒有請填 無"
                },
              ]
            when Step::VAT_NUMBER
              @sourceable[:order][:params][:vat] = (message == '無' ? '' : message.to_i)

              @sourceable[:order][:step] = Step::CAPTCHA

              response = TraBento.captcha
              @sourceable[:order][:captcha_binary] = Base64.encode64(response.body)
              @sourceable[:order][:cookies]        = response.cookies
              save_sourceable!

              reply_messages = [
                {
                  type: 'text',
                  text: "請輸入驗證碼(大小寫):"
                },
                {
                  type: 'image',
                  originalContentUrl: "#{ENV['BASE_URL']}/captcha/#{@sourceable[:sourceable_id]}.jpg",
                  previewImageUrl: "#{ENV['BASE_URL']}/captcha/#{@sourceable[:sourceable_id]}.jpg"
                }
              ]
            when Step::CAPTCHA
              @sourceable[:order][:params][:captcha] = message
              @sourceable[:order][:step] = Step::CONFIRM
              save_sourceable!

              msg = ''
              msg += "你的訂單資料為\n"
              msg += "身分證：#{sourceable[:order][:params][:id]}\n"
              msg += "預約號：#{sourceable[:order][:params][:resNo]}\n"
              msg += "排骨便當數量：#{sourceable[:order][:params][:ribsBox]}\n"
              msg += "素食便當數量：#{sourceable[:order][:params][:vegetarianBox]}\n"
              msg += "統一編號：#{sourceable[:order][:params][:vat]}\n"
              msg += "\n"
              msg += "確認無誤後，填入數字 yes或no\n"
              msg += "yes: 送出訂單\n"
              msg += "no: 取消訂單"

              reply_messages = {
                type: 'template',
                altText: msg,
                template: {
                  type: 'confirm',
                  text: msg,
                  actions: [
                    {
                      type: 'message',
                      label: 'Yes',
                      text: 'yes',
                    },
                    {
                      type: 'message',
                      label: 'No',
                      text: 'no',
                    },
                  ],
                }
              }
            when Step::CONFIRM
              sourceable_idle!

              if message == 'yes'
                cookies = sourceable[:order][:cookies]
                params  = sourceable[:order][:params]

                response = TraBento.order cookies, params
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
              else
                reply_messages = [
                  {
                    type: 'text',
                    text: '您已取消這次的訂單!'
                  },
                ]
              end
            end
          elsif message =~ /^(order|Order|訂便當)$/
            sourceable_order!

            reply_messages = [
              {
                type: 'text',
                text: "訂便當囉!!"
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
