class TigerTamer::Action::DefineTableFromShapefile
  pattr_initialize :db, :config, :shapefile, :table_name

  def define
    if exists?
      logger.debug(%|#{table_name} already exists.|)
    else
      logger.info("Generating schema for #{table_name}.")

      TigerTamer::Cli.run <<~EOC
        #{config.shp2pgsql_bin} -p -I -s #{TigerTamer::SRID} #{shapefile} #{table_name} |\
        #{config.psql_bin} -d #{config.connection}
      EOC
    end
  end

  private

  def exists?
    !db
      .exec(%|select to_regclass('#{table_name}') as exists|)
      .first['exists']
      .nil?
  end
end
