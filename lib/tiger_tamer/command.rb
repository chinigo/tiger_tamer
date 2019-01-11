require 'active_support/core_ext/string/inflections'

module TigerTamer::Command
  class << self
    def factory(command, pathspec, config)
      klass_for(command).new(pathspec, config)
    end

    private

    def klass_for(command)
      const_get("Load#{command.camelize}")
    rescue NameError
      raise Slop::Error, "Invalid command #{command} specified."
    end
  end

  class Base
    pattr_initialize :pathspec, :config

    def create_database!
      db_adapter.temp_connection do |tmp_conn|
        TigerTamer::Action::CreateDatabase
          .new(tmp_conn, db_adapter.db_name)
          .create
      end

      TigerTamer::Action::InstallPostGIS
        .new(db)
        .install
    end

    def drop_database!
      db_adapter.temp_connection do |tmp_conn|
        TigerTamer::Action::DropDatabase
          .new(tmp_conn, db_adapter.db_name)
          .drop
      end
    end

    private

    def files
      @files ||= file_expander.files
    end

    def db_adapter
      @db_adapter ||= TigerTamer::Database.new(config.connection)
    end

    def db
      @db ||= db_adapter.connection
    end
  end
end
