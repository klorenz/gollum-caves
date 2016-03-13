require 'gollum/views/edit'
require 'gollum-caves/view_wiki_mixin'

module Precious
  module Views
    class Edit
      include GollumCaves::ViewWikiMixin

      def editor_setup
        "#{@editor}_setup"
      end
      def editor_view
        @editor
      end

      attr_reader :filename

      attr_reader :redirect_url

      def has_redirect_url
        not @redirect_url.nil?
      end
    end
  end
end
