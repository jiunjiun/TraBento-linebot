class CaptchaController < ApplicationController
  def show
    data = Base64.decode64(sourceable[:order][:captcha_binary])

    send_data data, filename: "#{Time.now.to_i.to_s}.jpg", type: "image/jpeg", disposition: 'inline'
  end

  private
  def sourceable
    line_id = params[:id]

    result = $redis.get(line_id)
    return {} if result.blank?

    JSON.parse(result, symbolize_names: true)
  rescue
    {}
  end
end
