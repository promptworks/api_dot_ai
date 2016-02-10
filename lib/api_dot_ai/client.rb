require 'rubygems'
require 'bundler/setup'
require 'net/http'
require 'uri'
require 'json'

module ApiDotAi
  class FailedRequest < RuntimeError; end

  class Client
    BASE_URL = 'https://api.api.ai/v1/'
    attr_accessor :client_access_token, :subscription_key

    def initialize(client_access_token:, subscription_key:)
      @client_access_token = client_access_token
      @subscription_key    = subscription_key
    end

    def query
      QueryRequest.new
    end

    def make(request)
      uri           = URI("#{BASE_URL}#{request.path}")
      http_request  = Kernel.const_get("Net::HTTP::#{request.verb.capitalize}").new uri
      headers.each { |key, value| http_request[key] = value }
      http_request.body = request.body

      http = Net::HTTP.new(uri.host, uri.port)
      http.set_debug_output($stdout)
      if uri.scheme =~ /https/i
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http.request(http_request)
    end

    def make!(request)
      make(request).tap do |response|
        raise FailedRequest unless response.is_a?(Net::HTTPSuccess)
      end
    end

    private

    def headers
      {
        'Content-Type'              => 'application/json; charset=utf-8',
        'Authorization'             => "Bearer #{self.client_access_token}",
        'ocp-apim-subscription-key' => self.subscription_key
      }
    end
  end

  class QueryRequest
    DEFAULT_LANGUAGE = 'en'
    DEFAULT_TIMEZONE = 'en'
    QUERY_PATH = 'query?v=20150910'

    attr_accessor :client, :query, :timezone, :language, :contexts, :session_id

    def initialize(attributes = {})
      self.language = DEFAULT_LANGUAGE
      self.timezone = DEFAULT_TIMEZONE
      self.contexts = []
      attributes.each { |k,v| self.public_send "#{k}=", v }
    end

    def path
      QUERY_PATH
    end

    def verb
      'POST'
    end

    def body
      JSON.dump({
        'query'     => query,
        'timezone'  => timezone,
        'lang'      => language,
        'contexts'  => contexts,
        'sessionId' => session_id
      })
    end
  end
end
