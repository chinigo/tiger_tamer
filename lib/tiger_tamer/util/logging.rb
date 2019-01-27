include Logging.globally

class TigerTamer::Util::Logging
  def self.setup(log_file, stdout_verbose)
    raise RuntimeError if @already_setup

    Logging.init %i(trace debug info warn error fatal)

    ::Logging.color_scheme(
      :stdout_scheme,
      levels: {
        trace: %i(dark white),
        debug: :cyan,
        info:  :green,
        warn:  :yellow,
        error: :red,
        fatal: %i(white on_red)
      },
      logger:  :blue,
      message: :white
    )

    ::Logging.appenders.stdout(
      :stdout,
      layout: ::Logging.layouts.pattern(
        pattern:      '%-5l %c %m\n',
        color_scheme: :stdout_scheme,
        date_pattern: '%H:%M:%S.%s'
      ),
      level: stdout_verbose ? :trace : :info,
      sync: true
    )
    ::Logging.logger.root.add_appenders :stdout


    ::Logging.appenders.file(
      :file,
      filename: 'log/tame.log',
      layout: ::Logging.layouts.pattern(
        pattern:      '%-5l [%d] %c %m\n',
        color_scheme: false,
        date_pattern: '%H:%M:%S.%s'
      ),
      level: :trace,
      sync: true
    )

    ::Logging.logger.root.add_appenders :file

    Zeitwerk::Registry.loaders.each do |l|
      l.logger = Logging.logger['Zeitwerk'].method(:trace)
    end

    @already_setup = true
  end
end
