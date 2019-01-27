class TigerTamer::Command::LoadAll < TigerTamer::Command::Base
  def load_data
    %w(coastline states counties subdivisions water roads)
      .map {|dataset| TigerTamer::Command.factory(dataset, pathspec, config) }
      .each(&:load_data)
  end

  private

  def file_expander
    @file_expander ||= TigerTamer::Cli::FileExpander.new(pathspec, '*/*', true)
  end
end
