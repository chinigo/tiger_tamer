module TigerTamer::Command
  class LoadSubdivisions < Load
    def self.glob
      'COUSUB/tl_*_*_cousub.zip'
    end

    def self.desired_files
      'tl_*_*_cousub.*'
    end

    def self.table_name
      'tiger_subdivisions'
    end
  end
end
