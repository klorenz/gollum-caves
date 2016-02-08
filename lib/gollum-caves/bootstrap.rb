# does first initializations on start of rackapp

#puts Precious::App.settings

wiki_root = Precious::App.settings.gollum_caves.fetch(:wiki_root, File.expand_path("wiki"))
@wm = GollumCaves::WikiManager.new(wiki_root)
@wm.init()
