require 'gollum/views/edit'

module Precious
  module Views
    class Edit
      def editor_setup
        "#{@editor}_setup"
      end
      def editor_view
        @editor
      end
      attr_reader :filename
      attr_reader :wikicoll
      attr_reader :wikiname
      attr_reader :wikipath
      attr_reader :redirect_url

      def has_redirect_url
        not @redirect_url.nil?
      end
    end
  end
end
