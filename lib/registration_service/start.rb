module RegistrationService
  class Start
    def self.build
      instance = new
      instance
    end

    def call
      settings = Settings.instance

      registration_component_settings = settings.data.dig("registration_component")
      registration_message_store_settings = MessageStore::Postgres::Settings.build(registration_component_settings)

      player_email_address_component_settings = settings.data.dig("player_email_address_component")
      player_email_address_message_store_settings = MessageStore::Postgres::Settings.build(player_email_address_component_settings)

      registration_view_data_settings = settings.data.dig("registration_view_data")
      registration_view_data_message_store_settings = MessageStore::Postgres::Settings.build(registration_view_data_settings)

      ComponentHost.start('registration-service') do |host|
        registration_component_initiator = RegistrationComponent::Start.build(registration_message_store_settings)
        host.register(registration_component_initiator)

        player_email_address_component_initiator = PlayerEmailAddressComponent::Start.build(player_email_address_message_store_settings)
        host.register(player_email_address_component_initiator)

        # View Data

        registration_view_data_initiator = RegistrationViewData::Start.build(registration_message_store_settings)
        host.register(registration_view_data_initiator)

        # Data Commands

        registration_data_initiator = DataCommand::Start.build('registrationData', registration_view_data_message_store_settings)
        host.register(registration_data_initiator)
      end
    end
  end
end
