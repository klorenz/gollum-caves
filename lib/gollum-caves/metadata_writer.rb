module GollumCaves
  module MetaData
    class Writer
      def initialize(wikifile)
        @wikifile = wikifile
      end
    end

    class FrontMatterWriter < Writer

    end

    class Markdown < FrontMatterWriter

    end
  end
end
