class TigerTamer::Database
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

  pattr_initialize :uri

  def connection
    LoggingConnection.new(pg_connection(uri))
  end

  def temp_connection(&block)
    LoggingConnection.new(pg_connection(default_postgres_uri)).tap do |tmp_conn|
      yield tmp_conn
      tmp_conn.close
    end
  end

  def db_name
    URI.parse(uri).path.gsub(%r{^/}, '')
  end

  private

  def pg_connection(db_url)
    logger.info("Connecting to #{db_url}.")
    PG.connect(db_url).tap do |conn|
      conn.set_notice_receiver {|r| nil}
      conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)
    end
  rescue PG::ConnectionBad => e
    logger.error("Could not connect to #{db_url}.")
    raise e
  end

  def default_postgres_uri
    URI.parse(uri).tap { |u| u.path = '/postgres' }.to_s
  end
end
