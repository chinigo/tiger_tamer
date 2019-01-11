module TigerTamer::Command
  class LoadClippedCounties < Base
    def load_data
      logger.info("Loading #{table_name}.")

      drop_table! if config.drop_table

      define_table!
      insert_data!
    end

    private

    def insert_data!
      counties.each {|c| insert_county!(c['gid'], c['county_name'], c['state_name'])}
    end

    def insert_county!(gid, county_name, state_name)
      logger.info("Processing #{county_name} county, #{state_name}.")

      db.exec <<~EOQ
        INSERT INTO #{table_name} (
          tiger_id,
          state_id,
          fips,
          full_fips,
          name,
          area_land,
          geom
        )
        SELECT c.gid,
          null,
          c.countyfp,
          c.geoid,
          c.name,
          c.aland,
          ST_Multi(ST_Difference(c.geom, ST_Union(w.geom)))
        FROM tiger_counties c
        INNER JOIN tiger_water w
          ON ST_Intersects(w.geom, c.geom)
        WHERE c.gid = #{gid}
        GROUP BY c.gid
      EOQ
    end

    def define_table!
      db.exec <<~EOQ
        CREATE TABLE #{table_name} (
          id serial PRIMARY KEY,
          tiger_id int not null,
          state_id integer null,
          fips char(3) not null,
          full_fips char(5) not null,
          name varchar not null,
          area_land double precision not null,
          geom geometry(MultiPolygon, 4269) not null
        )
      EOQ

      db.exec %|CREATE INDEX #{table_name}_geom_idx ON #{table_name} USING GIST(geom)|
    end

    def drop_table!
      db.exec(%|DROP TABLE IF EXISTS #{table_name}|)
    end

    def counties
      db.exec <<~EOQ
        SELECT c.gid gid,
          c.name county_name,
          s.name state_name
        FROM #{LoadCounties.table_name} c
        INNER JOIN #{LoadStates.table_name} s
          ON s.statefp = c.statefp
        WHERE s.name = 'Florida'
        ORDER BY c.countyfp ASC
      EOQ
    end

    def table_name
      'counties'
    end
  end
end
