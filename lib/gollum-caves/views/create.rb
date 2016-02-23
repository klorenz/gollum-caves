require 'gollum/views/create'

module Precious
  module Views
    class Create
      def editor_setup
        "#{@editor}_setup"
      end
      def editor_view
        @editor
      end

      def page_dir
        @path.gsub(/\/#{@wikipath}/, '')
      end

      attr_reader :filename
      attr_reader :wikicoll
      attr_reader :wikiname
      attr_reader :wikipath
      def has_redirect_url
        not @redirect_url.nil?
      end
      attr_reader :redirect_url

    end
  end
end
