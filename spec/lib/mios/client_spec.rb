require 'spec_helper'

describe MiOS::Client do

  it "can create a new Client" do
    a = MiOS::Client.new('192.168.50.21:3480')
    expect(a).to be_a MiOS::Client
  end
end