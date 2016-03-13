module GollumCaves
  module ViewWikiMixin
    def wikiname
      @wiki.wikiname
    end
    def wikicoll
      @wiki.collname
    end
    def wikipath
      @wiki.wikipath
    end

    def has_other_wikis
      !other_wikis_list.empty?
    end

    def has_other_collections
      !other_collections_list.empty?
    end

    def other_wikis_list
      @other_wikis_list ||= @wm.list_wikis(wikicoll).select do |name|
        name != wikiname
      end.map do |name|
        { 'name' => name }
      end
    end

    def other_collections_list
      @other_collections_list ||= @wm.list_collections().select do |name|
        name != wikicoll
      end.map do |name|
        { 'name' => name }
      end
    end
  end
end
