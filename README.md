# tiger_tamer

```
$ ./bin/tame --help

Load TIGER shapefiles into relational PostGIS database.

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

  Content options:
    -d, --derive         Create derived, highly indexed tables. (Default: true)
    -p, --projection     Re-project derived tables to the specified SRID. (Default 4269)

  Database options:
    -c, --connection     Postgres connection URL. (Default: postgres://localhost/tiger)
    -D, --drop-database  Drop the database before beginning. (Default: false)
    -T, --drop-table     Drop existing table before loading data. (Default: false)

  Logging:
    -l, --log-file       Path to log file. (Default: <project_root>/log/tame.log)
    -v, --verbose        Enable verbose logging to STDOUT. (Log file is always verbose.)

  Binary locations:
    --pg-restore-bin     Path to pg_restore. (Default: `which pg_restore`)
    --psql-bin           Path to psql. (Default: `which psql`)
    --shp2pgsql-bin      Path to PostGIS's shp2pgsql binary. (Default: `which shp2pgsql`)
    --unzip-bin          Path to unzip (which must conform to Info-ZIP v6.0's interface). (Default: `which unzip`)
    --help               Print this help message.


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

  Create tailored, derived tables with foreign keys (default behavior):
    $ tame states --derived ./TIGER/2018
    $ tame counties --derived ./TIGER/2018

  Skip derived tables to save space:
    $ tame states --no-derived ./TIGER/2018

  Re-project derived tables (SRID must exist in spatial_ref_sys):
    $ tame all --projection 4326 ./TIGER/2018

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
```
