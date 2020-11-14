module RegistrationViewData
  module Handlers
    module Registration
      class Events
        include Log::Dependency
        include Messaging::Handle
        include Messaging::StreamName
        include ::Registration::Client::Messages::Events

        dependency :session, Session
        dependency :write, Messaging::Postgres::Write
        dependency :get_last, MessageStore::Postgres::Get::Stream::Last

        def configure
          Session.configure(self)
          Messaging::Postgres::Write.configure(self, session: session)
          MessageStore::Postgres::Get::Stream::Last.configure(self, session: session)
        end

        category :registration_data

        handle Registered do |registered|
          registration_id = registered.registration_id
          player_id = registered.player_id
          email_address = registered.email_address
          time = registered.time
          position = registered.metadata.position

          stream_name = stream_name(registration_id)

          if current?(registered)
            logger.info(tag: :ignored) { "Event ignored (Event: #{registered.message_type}, Registration ID: #{registration_id})" }
            return
          end

          create_command = ViewData::Commands::Create.follow(registered, strict: false)
          create_command.name = 'registrations'
          create_command.identifier = {
            :registration_id => registration_id
          }
          create_command.data = {
            :player_id => player_id,
            :email_address => email_address,
            :is_email_rejected => false,
            :is_registered => true,
            :position => position,
            :created_at => time,
            :updated_at => time
          }

          write.(create_command, stream_name)
        end

        handle EmailRejected do |email_rejected|
          registration_id = email_rejected.registration_id
          player_id = email_rejected.player_id
          email_address = email_rejected.email_address
          time = email_rejected.time
          position = email_rejected.metadata.position

          stream_name = stream_name(registration_id)

          if current?(email_rejected)
            logger.info(tag: :ignored) { "Event ignored (Event: #{email_rejected.message_type}, Registration ID: #{registration_id})" }
            return
          end

          create_command = ViewData::Commands::Create.follow(email_rejected, strict: false)
          create_command.name = 'registrations'
          create_command.identifier = {
            :registration_id => registration_id
          }
          create_command.data = {
            :player_id => player_id,
            :email_address => email_address,
            :is_email_rejected => true,
            :is_registered => false,
            :position => position,
            :created_at => time,
            :updated_at => time
          }

          write.(create_command, stream_name)
        end

        def current?(event)
          registration_id = event.registration_id

          data_command_stream = stream_name(registration_id)

          last_command = get_last.(data_command_stream)

          return false if last_command.nil?

          last_command_position = last_command.metadata[:causation_message_position]

          last_command_position >= event.metadata.position
        end
      end
    end
  end
end
