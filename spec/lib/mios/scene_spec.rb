require 'spec_helper'

module MiOS
  describe Scene do

    describe :run do
      it 'should run the scene' do
        VCR.use_cassette('data_request') do
          @mios = MiOS::Interface.new('http://192.168.50.21:3480')
        end
        VCR.use_cassette('run_scene') do
          scene = MiOS::Scene.new(@mios, 5)
          expect(scene.run).to eql('OK')
        end
      end
    end
  end
end
