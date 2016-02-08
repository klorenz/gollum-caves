require 'gollum/views/edit'

module Precious
  module Views
    class Edit
      attr_reader :editor
      def editor_setup
        "#{@editor}_setup"
      end
      attr_reader :filename
      attr_reader :wikicoll
      attr_reader :collname
      attr_reader :wikiname
      attr_reader :wikipath
      attr_reader :redirect_url
    end
  end
end
