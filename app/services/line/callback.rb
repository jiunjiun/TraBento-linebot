module Line
  class Callback < Base
    attr_reader :request, :templatable, :sourceable

    def initialize request
      @request = request
    end

    def self.validate_signature? request
      new(request).validate_signature?
    end

    def validate_signature?
      body      = @request.body.read
      signature = @request.env['HTTP_X_LINE_SIGNATURE']

      client.validate_signature(body, signature)
    end

    def self.parse request
      new(request).parse
    end

    def parse
      body   = request.body.read
      events = client.parse_events_from(body)
      events.each do |event|
        ScriptsBase.assign event
      end
    end
  end
end


