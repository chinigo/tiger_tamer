class TigerTamer::Action::InsertData
  pattr_initialize :config, :shapefiles, :table_name

  def load
    logger.info("Loading data into #{table_name}")
    shapefiles.each {|f| generate_dump(f)}
  end

  private

  def generate_dump(shapefile)
    TigerTamer::CLI.run <<~EOC
      #{config.shp2pgsql_bin} -a -s #{TigerTamer::SRID} -D #{shapefile} #{table_name} |\
      #{config.psql_bin} #{config.connection}
    EOC
  end
end
