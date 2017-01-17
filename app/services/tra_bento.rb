class TraBento
  # ----------------------------------------------------
  # API source - http://bentobox.goodideas-campus.com/
  # ----------------------------------------------------

  API_URL = 'http://bentobox.goodideas-campus.com'

  def self.captcha
    new.captcha
  end

  def self.order cookies, opts={}
    new.order cookies, opts
  end

  def self.update opts={}
    new.update opts
  end

  def self.cancel opts={}
    new.cancel opts
  end

  def self.query opts={}
    new.query opts
  end

  def self.search opts={}
    new.search opts
  end


  def captcha
    RestClient.get "#{API_URL}/captcha"
  end

  def order cookies, opts
    RestClient.post "#{API_URL}/order", opts, {cookies: cookies}
  end

  def update opts
    RestClient.post "#{API_URL}/update", opts
  end

  def cancel opts
    RestClient.post "#{API_URL}/cancel", opts
  end

  def query opts
    RestClient.post "#{API_URL}/query", opts
  end

  def search opts
    RestClient.post "#{API_URL}/search", opts
  end
end
