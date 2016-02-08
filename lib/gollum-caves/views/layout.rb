require 'gollum/views/layout'

module Gollum
  module Views
    class Layout
      def plugins
        @plugins.each do |plugin|
          Hash.new({
            :plugin_setup => "#{plugin}_setup"
          })
        end
      end
    end
  end
end
