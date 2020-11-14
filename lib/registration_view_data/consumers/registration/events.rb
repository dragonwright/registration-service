module RegistrationViewData
  module Consumers
    module Registration
      class Events
        include Consumer::Postgres

        identifier 'registrationViewData'

        handler Handlers::Registration::Events
      end
    end
  end
end
