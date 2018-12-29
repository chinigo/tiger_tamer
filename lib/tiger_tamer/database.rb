module TigerTamer
  class Database
    class LoggingConnection < SimpleDelegator
      def initialize(conn)
        super
      end

      def exec(sql)
        logger.debug(sql)
        super
      end

      def exec_params(*args)
        logger.debug(args[0])
        super
      end
    end # LoggingConnection

    class PostGISConnection < SimpleDelegator
      def initialize(conn)
        super
        install_extension unless has_extension?
      end

      private

      def install_extension
        logger.info('Installing postgis extension.')
        exec(%|CREATE EXTENSION postgis|)
      end

      def has_extension?
        logger.debug('Checking for postgis extension.')
        (!!exec(%|SELECT true AS exists FROM pg_extension WHERE extname = 'postgis'|).first).tap do |ext|
          logger.debug("postgis extension #{'not yet ' unless ext}installed.")
        end
      end
    end # PostGISConnection

    pattr_initialize :uri, :create_db, :drop_db

    def connection
      PostGISConnection.new(LoggingConnection.new(unwrapped_connection))
    end

    private

    def unwrapped_connection
      drop_database! if drop_db

      pg_connection(uri)
    rescue PG::ConnectionBad => e
      raise e unless create_db

      create_database!

      pg_connection(uri)
    end

    def drop_database!
      logger.info("Dropping database #{db_name}.")

      temp_connection.tap do |tmp|
        tmp.exec("DROP DATABASE IF EXISTS #{db_name}")
        tmp.close
      end
    end

    def create_database!
      logger.info("Creating database #{db_name}.")

      temp_connection.tap do |tmp|
        tmp.exec("CREATE DATABASE #{db_name}")
        tmp.close
      end
    end

    def temp_connection
      LoggingConnection.new(pg_connection(default_postgres_uri))
    end

    def default_postgres_uri
      URI.parse(uri).tap { |u| u.path = '/postgres' }.to_s
    end

    def pg_connection(db_url)
      logger.info("Connecting to #{db_url}.")
      PG.connect(db_url).tap do |conn|
        conn.set_notice_receiver {|r| nil}
      end
    rescue PG::ConnectionBad => e
      logger.error("Could not connect to #{db_url}.")
      raise e
    end

    def db_name
      URI.parse(uri).path.gsub(%r{^/}, '')
    end
  end
end
