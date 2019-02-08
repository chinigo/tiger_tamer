module TigerTamer::Command
  class LoadSubdivisions < Load
    class << self
      def has_derivations
        true
      end

      def glob
        'COUSUB/tl_*_*_cousub.zip'
      end

      def desired_files
        'tl_*_*_cousub.*'
      end

      def table_name
        'tiger_subdivisions'
      end

      def derived_table_name
        'subdivisions'
      end

      def derived_dependencies
        []
      end
    end

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

          county_id bigint NOT NULL
            REFERENCES #{LoadCounties.derived_table_name} (id)
            ON DELETE CASCADE,
          county_fips char(3) NOT NULL,
          full_fips char(5) NOT NULL,


          gid integer NOT NULL,
          name varchar(100) NULL DEFAULT NULL,
          feature_type varchar(5) NOT NULL,

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
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_full_fips_idx ON #{self.class.derived_table_name} (full_fips)",
        "CREATE UNIQUE INDEX IF NOT EXISTS #{self.class.derived_table_name}_gid_idx ON #{self.class.derived_table_name} (gid)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_feature_type_idx ON #{self.class.derived_table_name} (feature_type)",
        "CREATE INDEX IF NOT EXISTS #{self.class.derived_table_name}_geom_idx ON #{self.class.derived_table_name} USING GIST (geom)"
      ]
    end

    def copy_derived_data
      <<~EOQ
        INSERT INTO #{self.class.derived_table_name} (
          state_id,
          state_postal_code,
          state_fips,
          county_id,
          county_fips,
          full_fips,
          gid,
          name,
          feature_type,
          geom
        )
        SELECT
          c.state_id,
          c.state_postal_code,
          c.state_fips,
          c.id,
          c.fips,
          c.full_fips,
          r.gid,
          r.name,
          r.mtfcc,
          ST_Transform(r.geom, #{config.projection})
        FROM #{self.class.table_name} r
        INNER JOIN #{LoadCounties.derived_table_name} c
          ON ST_Contains(c.geom, ST_Transform(r.geom, #{config.projection}))
      EOQ
    end
  end
end
