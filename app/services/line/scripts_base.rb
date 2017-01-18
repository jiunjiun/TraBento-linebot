module Line
  class ScriptsBase < Base
    prepend Line::Scripts::HelpScript
    prepend Line::Scripts::SearchScript
    prepend Line::Scripts::OrderScript

    attr_reader :event
    attr_reader :sourceable

    module SourceableStatus
      IDLE   = 0
      SEARCH = 1
      ORDER  = 2
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
        sourceable_id = "u#{user_id}"
      when 'group'
        group_id = source['groupId']
        sourceable_id = "g#{user_id}"
      when 'room'
        room_id = source['roomId']
        sourceable_id = "r#{user_id}"
      end
      result = $redis.get sourceable_id

      if result.present?
        @sourceable = JSON.parse(result, symbolize_names: true)
      else
        @sourceable = { status: Line::ScriptsBase::SourceableStatus::IDLE, sourceable_id: sourceable_id}
        save_sourceable!
      end
    rescue
      @sourceable = { status: Line::ScriptsBase::SourceableStatus::IDLE, sourceable_id: sourceable_id}
      save_sourceable!
    end

    def save_sourceable!
      source = event['source']

      case source['type']
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

    def sourceable_idle!
      @sourceable[:status] = Line::ScriptsBase::SourceableStatus::IDLE
      save_sourceable!
    end

    def sourceable_search!
      @sourceable[:status] = Line::ScriptsBase::SourceableStatus::SEARCH
      save_sourceable!
    end

    def sourceable_order!
      @sourceable[:status] = Line::ScriptsBase::SourceableStatus::ORDER
      @sourceable[:order] = {
        step: Line::Scripts::OrderScript::Step::ID_NUMBER,
        cookies: nil,
        captcha_binary: nil,
        params: {
          captcha: '',
          id: '',
          resNo: '',
          ribsBox: '',
          vegetarianBox: '',
          vat: '',
        }
      }
      save_sourceable!
    end
  end
end
