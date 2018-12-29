class TigerTamer::CLI::FileExpander
  pattr_initialize :pathspec, :glob do
    validate
  end

  def files
    @files ||= filenames.map {|f| File.expand_path(f, pathspec.first) }
  end

  private

  def validate
    if pathspec.empty?
      raise Slop::Error, 'Must specify a root directory or file list.'
    end

    if (nonexistent_file = pathspec.detect {|ps| !File.exists?(ps) })
      raise Slop::Error, "Specified nonexistent root directory or file: #{nonexistent_file}."
    end

    if directory? && pathspec.count > 1
      raise Slop::Error, 'Cannot specify both a root directory and individual files.'
    end
  end

  def filenames
    return pathspec unless directory?

    Dir.glob(glob, base: pathspec.first).tap do |matches|
      if matches.empty?
        raise Slop::Error, "Could not find any files matching glob #{glob} within #{pathspec.first}."
      end
    end
  end

  def directory?
    @directory ||= pathspec.any? {|ps| File.directory?(ps) }
  end
end
