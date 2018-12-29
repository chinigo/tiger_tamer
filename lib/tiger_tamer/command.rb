module TigerTamer::Command
  class << self
    def factory(command, config, pathspec)
      klass_for(command).new(pathspec, config)
    end

    private

    def klass_for(command)
      const_get("Load#{command.capitalize}")
    rescue NameError
      raise Slop::Error, "Invalid command #{command} specified."
    end
  end
end
