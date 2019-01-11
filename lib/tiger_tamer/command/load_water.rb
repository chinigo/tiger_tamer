module TigerTamer::Command
  class LoadWater < Load
    def self.glob
      'AREAWATER/tl_*_*_areawater.zip'
    end

    def self.desired_files
      'tl_*_*_areawater.*'
    end

    def self.table_name
      'tiger_water'
    end
  end
end
