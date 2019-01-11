class TigerTamer::Command::Load < TigerTamer::Command::Base
  def load_data
    logger.info("Loading #{self.class.table_name}.")

    drop_table! if config.drop_table
    define_table!
    insert_data!

    zipfiles.each(&:clean)
  end

  private

  def file_expander
    @file_expander ||= TigerTamer::CLI::FileExpander.new(pathspec, self.class.glob, false)
  end

  def zipfiles
    @zipfiles ||= files.map do |f|
      TigerTamer::Action::UnzipFile.new(config.unzip_bin, f, self.class.desired_files)
    end
  end

  def shapefiles
    @shapefiles ||= zipfiles.map(&:shapefile)
  end

  def insert_data!
    TigerTamer::Action::InsertData
      .new(config, shapefiles, self.class.table_name)
      .load
  end

  def define_table!
    TigerTamer::Action::DefineTableFromShapefile
      .new(db, config, shapefiles.first, self.class.table_name)
      .define
  end
end
