module TigerTamer::Command
  class LoadCounties < Load
    def glob
      'COUNTY/tl_*_us_county.zip'
    end

    def desired_files
      'tl_*_us_county.*'
    end

    def table_name
      'tiger_counties'
    end
  end
end
