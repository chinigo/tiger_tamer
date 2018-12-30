class TigerTamer::CLI::FileExpander
  pattr_initialize :pathspec, :glob, :require_directory do
    validate
  end

  def files
    @files ||= filenames.map {|f| File.expand_path(f, (pathspec.first if directory?)) }
  end

  private

  def validate
    if pathspec.empty?
      raise Slop::Error, require_directory ?
        'Must specify root TIGER directory.' :
        'Must specify root TIGER directory or file list.'
    end

    if (nonexistent_file = pathspec.detect {|ps| !File.exists?(ps) })
      raise Slop::Error, require_directory ?
        "Specified nonexistent root TIGER directory: #{nonexistent_file}." :
        "Specified nonexistent root TIGER directory or files: #{nonexistent_file}."
    end

    if require_directory && !directory?
      raise Slop::Error, 'Must provide root TIGER directory.'
    end

    if directory? && pathspec.count > 1
      raise Slop::Error, 'Cannot specify both a root TIGER directory and individual files.'
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
