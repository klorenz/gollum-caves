require 'gollum/views/edit'

module Precious
  module Views
    class Edit
      def editor_markdown
        @editor_markdown
      end
      def editor_source
        @editor_source
      end
      def editor_svg
        @editor_svg
      end
      def filename
        @filename
      end
      def wikicoll
        @wikicoll
      end
      def wikiname
        @wikiname
      end
      def wikipath
        @wikipath
      end
      def redirect_url
        @redirect_url
      end
    end
  end
end
