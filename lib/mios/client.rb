module MiOS
  class Client

    def initialize(base_uri)
      @base_uri = base_uri
      @client = HTTPClient.new
    end

    def json_data_request(params)
      MultiJson.load(@client.get("#{@base_uri}/data_request", params).content)
    end

  end
end