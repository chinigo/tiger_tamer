class TigerTamer::Action::DefineTableFromDdl
  pattr_initialize :db, :config, :ddl, :table_name

  def define
    logger.info("Defining table #{table_name} to hold derived data.")
    ddl.each do |statement|
      db.exec(statement)
    end
  end
end
