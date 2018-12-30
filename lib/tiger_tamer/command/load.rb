class TigerTamer::Command::Load
  def initialize(pathspec, config)
    @files = TigerTamer::CLI::FileExpander.new(pathspec, glob, false).files
    @config = config
  end

  def load_data
    logger.info("Loading #{table_name}.")

    drop_table! if config.drop_tables
    define_table! if config.create_tables
    insert_data!

    zipfiles.each(&:clean)
  end

  private

  attr_reader :files, :config

  def db
    @db ||= TigerTamer::Database.new(
      config.connection,
      config.create_database,
      config.drop_database
    ).connection
  end

  def zipfiles
    @zipfiles ||= files.map do |f|
      TigerTamer::Action::UnzipFile.new(config.unzip_bin, f, desired_files)
    end
  end

  def shapefiles
    @shapefiles ||= zipfiles.map(&:shapefile)
  end

  def drop_table!
    TigerTamer::Action::DropTable
      .new(db, table_name)
      .drop
  end

  def insert_data!
    TigerTamer::Action::InsertData
      .new(config, shapefiles, table_name)
      .load
  end

  def define_table!
    TigerTamer::Action::DefineTable
      .new(db, config, shapefiles.first, table_name)
      .define
  end
end
