module TigerTamer::Command
  class LoadWater < Load
    def glob
      'AREAWATER/tl_*_*_areawater.zip'
    end

    def desired_files
      'tl_*_*_areawater.*'
    end

    def table_name
      'tiger_water'
    end
  end
end
