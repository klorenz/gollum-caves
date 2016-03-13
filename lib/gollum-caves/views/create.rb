require 'gollum/views/create'
require 'gollum-caves/view_wiki_mixin'

module Precious
  module Views
    class Create
      include GollumCaves::ViewWikiMixin

      attr_reader :filename

      def editor_setup
        "#{@editor}_setup"
      end
      def editor_view
        @editor
      end

      def page_dir
        @path.gsub(/\/#{@wikipath}/, '')
      end

      def has_redirect_url
        not @redirect_url.nil?
      end

      attr_reader :redirect_url


    end
  end
end
