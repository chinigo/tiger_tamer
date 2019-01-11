module TigerTamer::Command
  class LoadStates < Load
    def self.glob
      'STATE/tl_*_us_state.zip'
    end

    def self.desired_files
      'tl_*_us_state.*'
    end

    def self.table_name
      'tiger_states'
    end
  end
end

