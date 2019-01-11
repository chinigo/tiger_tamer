module TigerTamer::Command
  class LoadRoads < Load
    def self.glob
      'ROADS/tl_*_*_roads.zip'
    end

    def self.desired_files
      'tl_*_*_roads.*'
    end

    def self.table_name
      'tiger_roads'
    end
  end
end

