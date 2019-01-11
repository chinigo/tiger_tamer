class TigerTamer::Action::DropDatabase
  pattr_initialize :conn, :db_name

  def drop
    logger.info("Dropping database #{db_name}.")

    conn.exec("DROP DATABASE IF EXISTS #{db_name}")
  end
end
