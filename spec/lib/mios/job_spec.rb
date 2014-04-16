require 'spec_helper'

describe MiOS::Job do

  describe 'status methods'
  let(:j) do
    interface = double('interface', data_request: '')
    device = double('device', interface: interface)
    j = MiOS::Job.new(device, 1)
  end
  let(:statuses) { j.class::STATUS }

  it 'has boolean methods for each status' do
    statuses.each do |status_num, status_name|
      n = status_name.downcase.gsub(' ', '_') + '?'
      j.methods.should include(n.to_sym)
    end
  end

  it 'has exists? method' do
    j.methods.should include(:exists?)
  end
end
