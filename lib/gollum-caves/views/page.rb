require 'nokogiri'
require 'gollum/views/page'

module Precious
  module Views
    class Page
      attr_reader :wikicoll
      attr_reader :wikiname
      attr_reader :wikipath
      attr_reader :filename

      def page_dir
        File.dirname(@filename.gsub(/\/#{@wikipath}/, ''))
      end

      def has_other_wikis
        !other_wikis_list.empty?
      end

      def has_other_collections
        !other_collections_list.empty?
      end

      def other_wikis_list
        @other_wikis_list ||= @wm.list_wikis(@wikicoll).select do |name|
          name != @wikiname
        end.map do |name|
          { 'name' => name }
        end
      end

      def other_collections_list
        @other_collections_list ||= @wm.list_collections().select do |name|
          name != @wikicoll
        end.map do |name|
          { 'name' => name }
        end
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
