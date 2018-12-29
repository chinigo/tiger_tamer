class TigerTamer::Action::UnzipFile
  pattr_initialize :unzip_bin, :zipfile, :desired_files

  def contents
    @contents ||= build_contents
  end

  def shapefile
    @shapefile ||= contents.detect {|f| f.end_with? '.shp'}
  end

  def clean
    logger.debug("Removing temp directory #{tmp_dir}.")
    FileUtils.remove_entry tmp_dir
  end

  private

  def build_contents
    logger.debug("Decompressing #{zipfile}.")
    unzip!

    Dir.new(tmp_dir).children.map {|f| File.expand_path(f, tmp_dir)}
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir
  end

  def unzip!
    TigerTamer::CLI.run %|#{unzip_bin} #{zipfile} #{desired_files} -d #{tmp_dir}|
  end
end
