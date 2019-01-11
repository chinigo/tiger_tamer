module TigerTamer::Command
  class LoadCoastline < Load
    def self.glob
      'COASTLINE/tl_*_us_coastline.zip'
    end

    def self.desired_files
      'tl_*_us_coastline.*'
    end

    def self.table_name
      'tiger_coastline'
    end
  end
end
