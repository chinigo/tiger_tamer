class TigerTamer::CLI::Tame
  Config = Struct.new(
    :connection,      # URL to postgres database
    :drop_database,   # Drop the database before beginning. (Default: false)
    :drop_table,      # Drop existing table before loading data. (Default: false)
    :log_file,        # Path to log file. (Default: <project_root>/log/tame.log)
    :verbose,         # Enable verbose logging to STDOUT. (Log file is always verbose.)
    :pg_restore_bin,  # Path to pg_restore. (Default: `which pg_restore`)
    :psql_bin,        # Path to psql. (Default: `which psql`)
    :shp2pgsql_bin,   # Path to PostGIS's shp2pgsql binary. (Default: `which shp2pgsql`)
    :unzip_bin        # Path to unzip utility. (Default: `which unzip`)
  )

  pattr_initialize :args

  def run
    command.drop_database! if config.drop_database
    command.create_database!
    command.load_data
  end

  private

  def command
    @command ||= begin
      TigerTamer::Util::Logging.setup(config.log_file, config.verbose)

      print_help_and_exit(0) if command_name == 'help'

      TigerTamer::Command.factory(command_name, parsed.arguments, config)
    rescue Slop::Error => e
      logger.error(e.message)
      logger.debug(e.backtrace.join("\n"))
      print_help_and_exit(1)
    end
  end

  def print_help_and_exit(exit_code)
    puts opts.to_s(prefix: '    ')
    exit(exit_code)
  end

  def command_name
    @command ||= parsed.arguments.shift.tap do |cmd|
      raise Slop::Error, 'Must specify command.' if cmd.nil?
    end
  end

  def parsed
    @parsed ||= Slop::Parser.new(opts).parse(args)
  end

  def config
    @config ||= Config.new(*parsed.to_h.values_at(*Config.members))
  end

  def opts
    Slop::Options.new do |o|
      o.banner = 'Load TIGER shapefiles into relational PostGIS database.'

      o.separator <<~EOD

      usage: <command> [options] <pathspec>


      Commands:
        all           Load all files present in root TIGER directory.
        coastline     Load TIGER coastline.
        states        Load TIGER states. (Depends on coastline.)
        counties      Load TIGER counties. (Depends on states.)
        subdivisions  Load TIGER county subdivisions. (Depends on counties.)
        water         Load TIGER bodies of water. (Depends on counties.)
        roads         Load TIGER roads. (Depends on counties.)
        help          Print this help message.


      Options:
        <pathspec>
          Either the path to the root TIGER directory for a given year, or a list of individual zip files.

          If the root TIGER directory is supplied, the appropriate subdirectory for the command is searched.
          The following directory structure is assumed:
            - Coastline:           <root>/COASTLINE/tl_<year>_us_coastline.zip
            - State boundaries:    <root>/STATE/tl_<year>_us_state.zip
            - County boundaries:   <root>/COUNTY/tl_<year>_us_county.zip
            - County subdivisions: <root>/COUSUB/tl_<year>_<state FIPS code>_cousub.zip
            - Water:               <root>/AREAWATER/tl_<year>_<county FIPS code>_areawater.zip
            - Roads:               <root>/ROADS/tl_<year>_<county FIPS code>_roads.zip

          If a list of files is supplied, no directory structure is assumed.

          You must specify the root TIGER directory for the 'all' command.
      EOD

      o.separator '  Database options:'

      o.string '-c',
        '--connection',
        'Postgres connection URL. (Default: postgres://localhost/tiger)',
        default: 'postgres://localhost/tiger'

      o.bool '-D',
        '--drop-database',
        'Drop the database before beginning. (Default: false)',
        default: false

      o.bool '-T',
        '--drop-table',
        'Drop existing table before loading data. (Default: false)',
        default: false


      o.separator ''
      o.separator '  Logging:'

      o.string '-l',
        '--log-file',
        'Path to log file. (Default: <project_root>/log/tame.log)',
        default: File.expand_path('../log/tame.log', __FILE__)

      o.bool '-v',
        '--verbose',
        'Enable verbose logging to STDOUT. (Log file is always verbose.)',
        default: false


      o.separator ''
      o.separator '  Binary locations:'

      o.string '--pg-restore-bin',
        'Path to pg_restore. (Default: `which pg_restore`)',
        default: `which pg_restore`.chomp

      o.string '--psql-bin',
        'Path to psql. (Default: `which psql`)',
        default: `which psql`.chomp

      o.string '--shp2pgsql-bin',
        'Path to PostGIS\'s shp2pgsql binary. (Default: `which shp2pgsql`)',
        default: `which shp2pgsql`.chomp

      o.string '--unzip-bin',
        'Path to unzip (which must conform to Info-ZIP v6.0\'s interface). (Default: `which unzip`)',
        default: `which unzip`.chomp

      o.on '--help', 'Print this help message.' do
        print_help_and_exit(0)
      end

      o.separator <<~EOD


      Examples:
        Load an entire or a partially-downloaded TIGER dataset into a local database:
          $ tame all ./TIGER/2018

        Erase database before starting over:
          $ tame all --drop-database ./TIGER/2018

        Or erase a particular table:
          $ tame counties --drop-table ./TIGER/2018

        Using an external database:
          $ tame all --connection postgres://maps.chinigo.net/tiger_2018 ./TIGER/2018

        Load just county subdivisions in New York:
          $ tame subdivisions ./TIGER/2018/COUSUB/tl_2018_36_cousub.zip

        Load county subdivisions for all of New England:
          $ tame subdivisions ./TIGER/2018/COUSUB/tl_2018_{09,23,25,33,44,50}_cousub.zip

        Multiple partial loads:
          $ tame subdivisions --drop-table ./TIGER/2018/COUSUB/tl_2018_36_cousub.zip
          $ tame subdivisions --no-drop-table ./TIGER/2018/COUSUB/tl_2018_37_cousub.zip
          $ tame subdivisions --no-drop-table ./TIGER/2018/COUSUB/tl_2018_38_cousub.zip

        If your PostGIS installation isn't on your $PATH:
          $ tame all --shp2pgsql-bin=/var/postgis/bin/shp2pgsql ./TIGER/2018


      Requirements:
        - PostGIS (for its shp2pgsql script)
        - pg_restore
        - psql
        - Info-ZIP v6.0
      EOD
    end
  end
end
