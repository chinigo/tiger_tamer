class TigerTamer::Action::CopyDerivedData
  pattr_initialize :db, :config, :statements, :table_name

  def copy
    logger.info("Copying derived data into #{table_name}.")

    statements.each do |statement|
      db.exec(statement)
    end
  end
end
