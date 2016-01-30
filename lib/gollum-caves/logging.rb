module GollumCaves
  module Logging

    def self.included base
      base.send :include, LoggingMethods
      base.extend LoggingMethods
    end

    module LoggingMethods
      def logger
        unless $LOG
          $LOG = Logger.new(STDOUT)
          $LOG.formatter = proc do |severity, datetime, progname, msg|
            "[#{severity}] #{progname}: #{msg}\n"
          end
        end
        $LOG
      end

      def log_debug(message)
        message.split("\n").each { |msg|
          logger.debug(self.class.name) { msg }
        }
      end

      def log_info(message)
        message.split("\n").each { |msg|
          logger.info(self.class.name) { msg }
        }
      end

      def log_warn(message)
        message.split("\n").each { |msg|
          logger.warn(self.class.name) { msg }
        }
      end

      def log_error(message)
        message.split("\n").each { |msg|
          logger.error(self.class.name) { msg }
        }
      end

      def log_fatal(message)
        message.split("\n").each { |msg|
          logger.fatal(self.class.name) { msg }
        }
      end

      def log_unknown(message)
        message.split("\n").each { |msg|
          logger.unknown(self.class.name) { msg }
        }
      end
    end
  end
end
