require 'gollum/views/create'

module Precious
  module Views
    class Create
      def editor_setup
        "#{@editor}_setup"
      end
      def page_dir
        @path.gsub(/\/#{@wikipath}/, '')
      end
      attr_reader :editor
      attr_reader :filename
      #attr_reader :collname
      attr_reader :wikicoll
      attr_reader :wikiname
      attr_reader :wikipath
      attr_reader :redirect_url
    end
  end
end
