module TigerTamer::Command
  class LoadStates < Load
    class << self
      def has_derivations
        true
      end

      def glob
        'STATE/tl_*_us_state.zip'
      end

      def desired_files
        'tl_*_us_state.*'
      end

      def table_name
        'tiger_states'
      end

      def derived_table_name
        'states'
      end

      def derived_dependencies
        [LoadCounties, LoadWater, LoadRoads]
      end
    end # self

    private

    def define_derived_table
      <<~EOQ
        CREATE TABLE IF NOT EXISTS #{self.class.derived_table_name} (
          id bigserial PRIMARY KEY,
          fips char(2) NOT NULL,
          name varchar NOT NULL,
          postal_code char(2) NOT NULL,
          geom geometry(MultiPolygon, #{config.projection}) NOT NULL
        )
      EOQ
    end

    def add_derived_indexes
      [
        "CREATE UNIQUE INDEX IF NOT EXISTS #{self.class.derived_table_name}_fips_idx ON #{self.class.derived_table_name} (fips)",
        "CREATE UNIQUE INDEX IF NOT EXISTS #{self.class.derived_table_name}_postal_code_idx ON #{self.class.derived_table_name} (postal_code)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_geom_idx ON #{self.class.derived_table_name} USING GIST (geom)"
      ]
    end

    def copy_derived_data
      <<~EOQ
        INSERT INTO #{self.class.derived_table_name}
          ( fips, name, postal_code, geom)
        SELECT
          s.statefp,
          s.name,
          s.stusps,
          ST_Transform(s.geom, #{config.projection})
        FROM #{self.class.table_name} s
      EOQ
    end
  end
end
