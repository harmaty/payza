require 'httparty'

class Payza

  SANDBOX_URL = 'https://sandbox.payza.com/api/api.svc/'
  API_URL = 'https://api.payza.com/svc/api.svc/'

  def initialize(account, api_secret, sandbox = false)
    @url = sandbox ? SANDBOX_URL : API_URL
    @account = account
    @api_secret = api_secret
  end

  def get_balance
    response = api_call({}, 'GetBalance')
    response['AVAILABLEBALANCE_1'].to_f
  end

  def api_call(data, method)
    data.merge!({"USER" => @account, "PASSWORD" => @api_secret})
    query = {}
    data.each do |key, value|
      query[key.to_s.upcase] = URI.escape(value.to_s)
    end

    parse_response HTTParty.post(@url + method, body: query)
  end

  def parse_response(input)
    @response = Rack::Utils.parse_nested_query(input)
    if @response["RETURNCODE"] == "100"
      @response
    else
      raise PayzaApiError, @response['DESCRIPTION']
    end
  end
end

class PayzaApiError < StandardError
end

