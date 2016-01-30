# does first initializations on start of rackapp

require 'gollum-caves/wiki_manager'

puts Precious::App.settings.gollum_caves[:wiki_root]

module GollumCaves::Bootstrap
  wiki_manager = GollumCaves::WikiManager.new({
    :wiki_root          => Precious::App.settings.gollum_caves[:wiki_root],
    :meta_wiki_name     => "me",
    :main_coll_name     => "wiki",
    # this is for landing
    :default_collection => "wiki",
    :default_wiki       => "me",
  })

  bare = false

  if not wiki_manager.exists_collection? "wiki"
    wiki_manager.create_collection("wiki", bare: bare)

    Precious::App.settings.gollum_caves[:initial_redirect] = "/wiki/me/Getting-Started"
  end

  if not wiki_manager.exists_collection? "wiki-plugins"
    wiki_manager.create_collection("wiki-plugins", bare: false)
  end

end
