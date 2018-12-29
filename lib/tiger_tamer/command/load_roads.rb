module TigerTamer::Command
  class LoadRoads < Load
    def glob
      'ROADS/tl_*_*_roads.zip'
    end

    def desired_files
      'tl_*_*_roads.*'
    end

    def table_name
      'tiger_roads'
    end
  end
end

