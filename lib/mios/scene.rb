module MiOS
  class Scene
    attr_accessor :id

    def initialize(interface, id)
      @interface = interface
      @id = id
    end

    def run
      response = Action.new(@interface,
        'urn:micasaverde-com:serviceId:HomeAutomationGateway1',
        'RunScene', 'SceneNum' => @id).take
      response.values.first.values.first
    end
  end
end
