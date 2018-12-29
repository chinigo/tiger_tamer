module TigerTamer::Command
  class LoadCoastline < Load
    def glob
      'COASTLINE/tl_*_us_coastline.zip'
    end

    def desired_files
      'tl_*_us_coastline.*'
    end

    def table_name
      'tiger_coastline'
    end
  end
end
