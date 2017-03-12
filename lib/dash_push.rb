require "dash_push/version"
require 'httpclient'

module DashPush
  class << self
    def network_device_name=(device)
      @network_device_name = device
    end

    def network_device_name
      @network_device_name || ENV['DASH_PUSH_DEVICE_NAME']
    end
  end

  class ActionBuilder
    def self.setup(params)
      case params['action']
      when 'http'
        HTTPAction.new(params['parameter'])
      end
    end

    class HTTPAction
      def initialize(params)
        parse_params(params)
      end

      def run!
        client = HttpClient.new
        query  = @parameter_builder.build if @method == 'get'
        body   = @parameter_builder.build if @method != 'get'

        client.request(@method, @uri, query, body)
      end

      private

      def parse_params(params)
        @uri               = params['uri']
        @method            = params['method'] || 'post'
        @parameter_builder = ParameterBuilder.new(params['params'])
      end
    end
  end

  class ParameterBuilder
    def initialize(params)
      @params = params
    end

    def build
      params.map {|key, value|
        [key, parse(value)]
      }.to_h
    end

    private

    def parse(value)
      case value
      when String
        value
      else
        ''
      end
    end
  end

  class Button
    def initialize(mac_address, params)
      @mac_address = mac_address
      @button      = Dashed::Button.new(@mac_address, DashPush.network_device_name)
      @action      = ActionBuilder.setup(params)
    end

    def ready!
      @button.on_press do
        push!
      end
    end

    def push!
      @action.run!
    end
  end
end
