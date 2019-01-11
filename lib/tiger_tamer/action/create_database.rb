class TigerTamer::Action::CreateDatabase
  pattr_initialize :conn, :db_name

  def create
    if exists?
      logger.debug("Database #{db_name} already exists")
    else
      logger.info("Creating database #{db_name}.")
      conn.exec("CREATE DATABASE #{db_name}")
    end
  end

  private

  def exists?
    !!conn
      .exec(%|SELECT true FROM pg_database WHERE datname = '#{db_name}' LIMIT 1|)
      .first
  end
end

