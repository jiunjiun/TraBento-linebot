module Line
  class ScriptsBase < Base
    prepend Line::Scripts::HelpScript
    prepend Line::Scripts::SearchScript

    attr_reader :event
    attr_reader :sourceable

    module SourceableStatus
      IDLE   = 0
      SEARCH = 1
    end

    def self.assign event
      new(event).assign
    end

    def initialize event
      @event = event

      parse_sourceable event['source']
    end

    def assign
    end

    def parse_sourceable source
      case source['type']
      when 'user'
        user_id = source['userId']
        result = $redis.get "u#{user_id}"
      when 'group'
        group_id = source['groupId']
        result = $redis.get "g#{user_id}"
      when 'room'
        room_id = source['roomId']
        result = $redis.get "r#{user_id}"
      end

      @sourceable = JSON.parse(result, symbolize_names: true)
    rescue
      {}
    end

    def save_sourceable!
      case event['source']['type']
      when 'user'
        user_id = source['userId']
        $redis.set "u#{user_id}", sourceable.to_json
      when 'group'
        group_id = source['groupId']
        $redis.set "g#{user_id}", sourceable.to_json
      when 'room'
        room_id = source['roomId']
        $redis.set "r#{user_id}", sourceable.to_json
      end
    end
  end
end
