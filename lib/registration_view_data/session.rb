module RegistrationViewData
  class Session < MessageStore::Postgres::Session
    settings.each do |setting_name|
      setting setting_name
    end

    def self.build(settings: nil)
      registration_settings = RegistrationService::Settings.instance
      view_data_settings = registration_settings.data.dig("registration_view_data")

      settings = Settings.build(view_data_settings)

      super(settings: settings)
    end
  end
end
