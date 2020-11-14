module DataCommand
  class Start
    attr_accessor :stream_name,
                  :settings

    def initialize(stream_name)
      self.stream_name = stream_name
    end

    def self.build(stream_name, settings)
      instance = new(stream_name)
      instance.settings = settings
      instance
    end

    def call
      Consumer.start(stream_name, settings: settings)
    end
  end
end
