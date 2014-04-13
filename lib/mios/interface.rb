module MiOS
  class Interface
    attr_reader :attributes, :base_uri

    def initialize(base_uri)
      @client = MiOS::Client.new(base_uri)
      @base_uri = base_uri
      load_attributes
      load_devices
    end

    def refresh!
      @raw_data = nil
      load_attributes
      load_devices
    end

    def devices
      @devices.values
    end

    def categories
      binding.pry
      devices.map { |device| device.category }.uniq.sort
    end

    def device_names
      devices.map(&:name)
    end

    def method_missing(method, *args)
      if @attributes.has_key?(method.to_s)
        @attributes[method.to_s]
      else
        super
      end
    end

    def inspect
      "#<MiOS::Interface:0x#{'%x' % (self.object_id << 1)} @base_uri=#{@base_uri} @attributes=#{@attributes.inspect}>"
    end


  private
    def raw_data
      @raw_data ||= raw_data_request
    end

    def raw_data_request
      response = @client.data_request(id: "user_data")
      # return MultiJson.load(response.content) if response.ok?
      # raise 'Device not available'
    end

    def load_attributes
      @attributes = Hash[
        raw_data.select { |k, v|
          !raw_data[k].kind_of?(Hash) and !raw_data[k].kind_of?(Array)
        }.map { |k, v|
          [k.downcase, v]
        }
      ]

      # Convert some time objects
      ['loadtime', 'devicesync'].each do |attr|
        @attributes[attr] = Time.at(@attributes[attr].to_i)
      end
    end

    def load_devices
      @devices = Hash[
        raw_data['devices'].map { |device|
          [device['id'], Device.new(self, device)]
        }
      ]
    end
  end
end