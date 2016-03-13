require 'nokogiri'
require 'gollum/views/page'
require 'gollum-caves/view_wiki_mixin'

module Precious
  module Views
    class Page
      include GollumCaves::ViewWikiMixin

      attr_reader :filename

      def page_dir
        File.dirname(@filename.gsub(/\/#{wikipath}/, ''))
      end


      def has_page_templates
        false
      end

      def page_templates
        # [ { :name => "My Template", :new_page_name => "NewPage.md" } ]
        []
      end

      def attachments
      end
      def has_attachments
      end
    end
  end
end
