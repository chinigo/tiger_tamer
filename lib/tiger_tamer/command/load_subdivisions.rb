module TigerTamer::Command
  class LoadSubdivisions < Load
    def glob
      'COUSUB/tl_*_*_cousub.zip'
    end

    def desired_files
      'tl_*_*_cousub.*'
    end

    def table_name
      'tiger_subdivisions'
    end
  end
end
