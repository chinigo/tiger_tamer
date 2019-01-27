class TigerTamer::Command::Load < TigerTamer::Command::Base
  def load_data
    logger.info("Loading #{self.class.table_name}.")

    drop_table!(self.class.table_name) if config.drop_table
    define_table!
    insert_data!

    zipfiles.each(&:clean)

    if config.derive && self.class.has_derivations
      logger.info('Copying derived data.')
      if config.drop_table
        self.class.derived_table_names.each do |table|
          drop_table!(table)
        end
      end

      define_derived_table!
      copy_derived_data!
    end
  end

  private

  def self.has_derivations
    false
  end

  def derived_ddl
    [ define_derived_table, *add_derived_indexes ]
  end

  def derive_sql
    [ copy_derived_data ]
  end

  def file_expander
    @file_expander ||= TigerTamer::Cli::FileExpander.new(pathspec, self.class.glob, false)
  end

  def zipfiles
    @zipfiles ||= files.map do |f|
      TigerTamer::Action::UnzipFile.new(config.unzip_bin, f, self.class.desired_files)
    end
  end

  def shapefiles
    @shapefiles ||= zipfiles.map(&:shapefile)
  end

  def drop_table!(table_name)
    TigerTamer::Action::DropTable
      .new(db, table_name)
      .drop
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

  def define_derived_table!
    TigerTamer::Action::DefineTableFromDdl
      .new(db, config, derived_ddl, self.class.derived_table_name)
      .define
  end

  def copy_derived_data!
    TigerTamer::Action::CopyDerivedData
      .new(db, config, derive_sql, self.class.derived_table_name)
      .copy
  end

  def self.derived_table_names
    self.derived_dependencies.map(&:derived_table_name) << self.derived_table_name
  end
end
