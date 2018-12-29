require 'open3'

module TigerTamer::CLI
  def self.run(cmd, log_level=:trace)
    logger.send(log_level, cmd)

    Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
      threads = [thread]
      threads << Thread.new do
        until (raw_line = stdout.gets).nil? do
          logger.send(log_level, raw_line.chomp)
        end
      end

      threads << Thread.new do
        until (raw_line = stderr.gets).nil? do
          logger.send(log_level, raw_line.chomp)
        end
      end

      threads.each(&:join)
    end
  end
end
