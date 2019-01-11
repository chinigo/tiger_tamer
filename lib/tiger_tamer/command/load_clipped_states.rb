module TigerTamer::Command
  class LoadClippedStates < Base
    def load_data
      logger.info("Loading #{table_name}.")

      drop_table! if config.drop_table

      define_table!
      insert_data!
    end
    private

    def insert_data!
      states.each {|s| insert_state!(s['gid'], s['name'])}
    end

    def states
      db.exec <<~EOQ
        SELECT s.gid, s.name
        FROM tiger_states s
        ORDER BY s.name ASC
      EOQ
    end

    def insert_state!(gid, name)
      logger.info("Processing the great state of #{name}.")

      db.exec_params(insert_query, [gid])
    end

    def insert_query
      @insert_query ||= <<~EOQ
        INSERT INTO #{table_name} (
          tiger_id,
          fips,
          name,
          area_land,
          geom
        )
        SELECT s.gid,
          s.statefp,
          s.name,
          s.aland,
          _t.clipped
        FROM tiger_states s
        CROSS JOIN #{tmp_table} _t
        WHERE s.gid = $1
        GROUP BY s.gid
      EOQ
    end

    def define_temp_table!
      db.exec("DROP TABLE IF EXISTS #{tmp_table}")
      db.exec <<~EOQ
        CREATE TABLE #{tmp_table} (
          id serial PRIMARY KEY,
          sector geometry(Polygon, #{TigerTamer::SRID}),
          clipped geometry(MultiPolygon, #{TigerTamer::SRID})
        )
      EOQ

      db.exec <<~EOQ
        INSERT INTO #{tmp_table} (sector)
        SELECT s.geom
        FROM tiger_states s
        WHERE s.gid = '39'
      EOQ

      db.exec(%|SELECT |).field_values('id').each do |sector_id|
        db.exec <<~EOQ
          WITH diff AS (
            -- SELECT _t.id, ST_CollectionExtract(
            --   ST_Multi(
            --     ST_Difference(_t.sector, ST_Union(w.geom))
            --   ),
            --   3
            -- ) as clipped
            SELECT _t.id, ST_Multi(ST_Union(_t.sector)) as clipped
            FROM #{tmp_table} _t
            LEFT JOIN tiger_water w
              ON ST_Intersects(_t.sector, w.geom)
            WHERE _t.id = #{sector_id}
            GROUP BY _t.id
          )

          UPDATE #{tmp_table}
          SET clipped = diff.clipped
          FROM diff
          WHERE #{tmp_table}.id = diff.id
        EOQ
      end
    end

    def define_table!
      db.exec <<~EOQ
        CREATE TABLE IF NOT EXISTS #{table_name} (
          id serial PRIMARY KEY,
          tiger_id int not null,
          fips char(3) not null,
          name varchar not null,
          area_land double precision not null,
          geom geometry(MultiPolygon, 4269)
        )
      EOQ

      db.exec %|CREATE INDEX IF NOT EXISTS #{table_name}_geom_idx ON #{table_name} USING GIST(geom)|
    end

    def table_name
      'states'
    end

    def tmp_table
      "_tmp_#{table_name}"
    end
  end
end
