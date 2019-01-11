module TigerTamer::Command
  class LoadCounties < Load
    def self.glob
      'COUNTY/tl_*_us_county.zip'
    end

    def self.desired_files
      'tl_*_us_county.*'
    end

    def self.table_name
      'tiger_counties'
    end
  end
end
