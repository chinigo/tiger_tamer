class TigerTamer::Command::LoadAll
  def initialize(pathspec, config)
    @pathspec = pathspec
    @files = TigerTamer::CLI::FileExpander.new(pathspec, '*/*', true).files
    @config = config
  end

  def load_data
    %w(coastline states counties subdivisions water roads)
      .map {|dataset| TigerTamer::Command.factory(dataset, pathspec, config) }
      .each(&:load_data)
  end

  private

  attr_accessor :config, :pathspec
end
