module RegistrationViewData
  class Start
    include Initializer

    attr_accessor :settings

    def self.build(settings=nil)
      instance = new
      instance.settings = settings
      instance
    end

    def call
      Consumers::Registration::Events.start('registration', settings: settings)
    end
  end
end
