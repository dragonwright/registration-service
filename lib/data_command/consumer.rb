module DataCommand
  class Consumer
    include ::Consumer::Postgres

    handler Handler
  end
end
