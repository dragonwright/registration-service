module RegistrationService
  class Settings < ::Settings
    def self.instance
      @instance ||= build
    end

    def self.data_source
      Defaults.data_source
    end

    def self.names
      [
        :registration_component,
        :player_email_address_component,
        :view_data_pg
      ]
    end

    module Defaults
      def self.data_source
        ENV['REGISTRATION_SERVICE_SETTINGS_PATH'] || 'settings/registration_service.json'
      end
    end
  end
end
