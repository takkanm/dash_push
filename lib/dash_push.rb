require "dash_push/version"
require 'httpclient'

module DashPush
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
      parse_params(params)
    end

    def push!
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
