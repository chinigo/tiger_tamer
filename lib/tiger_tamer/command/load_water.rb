module TigerTamer::Command
  class LoadWater < Load
    class << self
      def has_derivations
        true
      end

      def glob
        'AREAWATER/tl_*_*_areawater.zip'
      end

      def desired_files
        'tl_*_*_areawater.*'
      end

      def table_name
        'tiger_water'
      end

      def derived_table_name
        'water'
      end

      def derived_dependencies
        []
      end
    end # self

    private

    def define_derived_table
      <<~EOQ
        CREATE TABLE IF NOT EXISTS #{self.class.derived_table_name} (
          id bigserial PRIMARY KEY,
          state_id bigint NOT NULL
            REFERENCES #{LoadStates.derived_table_name} (id)
            ON DELETE CASCADE,
          state_postal_code char(2) NOT NULL,
          state_fips char(2) NOT NULL,
          county_id bigint NOT NULL,
          county_fips char(3) NOT NULL,
          hydroid bigint NOT NULL,
          name varchar NULL,
          geom geometry(MultiPolygon, #{config.projection}) NOT NULL
        )
      EOQ
    end

    def add_derived_indexes
      [
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_state_id_idx ON #{self.class.derived_table_name} (state_id)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_state_postal_code_idx ON #{self.class.derived_table_name} (state_postal_code)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_state_fips_idx ON #{self.class.derived_table_name} (state_fips)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_county_id_idx ON #{self.class.derived_table_name} (county_id)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_county_fips_idx ON #{self.class.derived_table_name} (county_fips)",
        "CREATE UNIQUE INDEX IF NOT EXISTS #{self.class.derived_table_name}_hydroid_idx ON #{self.class.derived_table_name} (hydroid)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_geom_idx ON #{self.class.derived_table_name} USING GIST (geom)",
      ]
    end

    def copy_derived_data
      <<~EOQ
        INSERT INTO #{self.class.derived_table_name}
          (state_id, state_postal_code, state_fips, county_id, county_fips, hydroid, name, geom)
        SELECT
          s.id,
          s.postal_code,
          s.fips,
          c.id,
          c.fips,
          w.hydroid::bigint,
          w.fullname,
          ST_Transform(w.geom, #{config.projection})
        FROM #{self.class.table_name} w
        INNER JOIN #{LoadCounties.derived_table_name} c
          ON ST_Intersects(c.geom, ST_Transform(ST_Centroid(w.geom), #{config.projection}))
        INNER JOIN #{LoadStates.derived_table_name} s
          ON s.id = c.state_id
        ON CONFLICT (hydroid) DO NOTHING
      EOQ
    end
  end
end
