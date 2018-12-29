class TigerTamer::Action::DropTable
  pattr_initialize :db, :table_name

  def drop
    db.exec(%|DROP TABLE IF EXISTS #{table_name}|)
  end
end
