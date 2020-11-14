module DataCommand
  class Handler
    include Messaging::Handle
    include Log::Dependency

    include ViewData::Commands

    dependency :session, Session
    dependency :insert, ViewData::Postgres::Insert

    def configure
      Session.configure(self)
      ViewData::Postgres::Insert.configure(self, session: session)
    end

    handle Create do |create|
      insert.(create)
    end
  end
end
