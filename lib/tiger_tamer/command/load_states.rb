module TigerTamer::Command
  class LoadStates < Load
    def glob
      'STATE/tl_*_us_state.zip'
    end

    def desired_files
      'tl_*_us_state.*'
    end

    def table_name
      'tiger_states'
    end
  end
end

