require 'line/bot'
module Line
  class Base
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token  = ENV['LINE_CHANNEL_TOKEN']
      }
    end

    def get_profile user_id
      response = client.get_profile user_id
      case response
      when Net::HTTPSuccess then
        JSON.parse(response.body, symbolize_names: true)
      else
        {}
      end
    end

    def get_message_content message_id
      response = client.get_message_content(message_id)
      Rails.logger.info { " -- [GetMessageContent][Info]: #{response.to_json}" }
      tf = Tempfile.open(Time.now.to_i.to_s)
      tf.binmode
      tf.write(response.body)
      {file: tf, content_type: response['content-type']}
    end
  end
end
