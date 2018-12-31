require 'active_support/core_ext/string/inflections'

module TigerTamer::Command
  class << self
    def factory(command, pathspec, config)
      klass_for(command).new(pathspec, config)
    end

    private

    def klass_for(command)
      const_get("Load#{command.camelize}")
    rescue NameError
      raise Slop::Error, "Invalid command #{command} specified."
    end
  end
end
