require 'spec_helper'

describe MiOS::Client do

  it "can create a new Client" do
    client = MiOS::Client.new('0.0.0.0:3000')
    expect(client).to be_a MiOS::Client
  end

  describe "#data_request" do

    it "returns ruby object from parsed json" do
      VCR.use_cassette('data_request') do
        client = MiOS::Client.new('http://192.168.50.21:3480')
        test_params = {:id => "user_data", :output_format => :json}
        expect(client.data_request(test_params)).to eq MultiJson.load(File.read('spec/support/device_data/data_request.json'))
      end
    end
  end
end