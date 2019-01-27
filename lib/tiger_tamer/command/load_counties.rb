module TigerTamer::Command
  class LoadCounties < Load
    class << self
      def has_derivations
        true
      end

      def glob
        'COUNTY/tl_*_us_county.zip'
      end

      def desired_files
        'tl_*_us_county.*'
      end

      def table_name
        'tiger_counties'
      end

      def derived_table_name
        'counties'
      end

      def derived_dependencies
        [LoadRoads]
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
          fips char(3) NOT NULL,
          full_fips char(5) NOT NULL,
          name varchar NOT NULL,
          geom geometry(MultiPolygon, #{config.projection}) NOT NULL
        )
      EOQ
    end

    def add_derived_indexes
      [
        "CREATE UNIQUE INDEX IF NOT EXISTS #{self.class.derived_table_name}_full_fips_idx ON #{self.class.derived_table_name} (full_fips)",
        "CREATE UNIQUE INDEX IF NOT EXISTS #{self.class.derived_table_name}_fips_idx ON #{self.class.derived_table_name} (fips, state_id)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_state_fips_idx ON #{self.class.derived_table_name} (state_fips)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_state_id_idx ON #{self.class.derived_table_name} (state_id)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_state_postal_code_idx ON #{self.class.derived_table_name} (state_postal_code)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_geom_idx ON #{self.class.derived_table_name} USING GIST (geom)"
      ]
    end

    def copy_derived_data
      <<~EOQ
        INSERT INTO #{self.class.derived_table_name}
          ( state_id, state_postal_code, state_fips, fips, full_fips, name, geom)
        SELECT
          s.id,
          s.postal_code,
          s.fips,
          f.countyfp,
          s.fips || f.countyfp,
          f.name,
          ST_Transform(f.geom, #{config.projection})
        FROM #{self.class.table_name} f
        INNER JOIN #{LoadStates.derived_table_name} s
          ON s.fips = f.statefp
      EOQ
    end
  end
end
