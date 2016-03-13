require 'rspec'

require File.expand_path '../../lib/gollum-caves/wiki_manager', __FILE__
require File.expand_path '../../lib/gollum-caves/wiki', __FILE__
require File.expand_path '../../lib/gollum-caves/wikifile', __FILE__

describe "GollumCaves::WikiFile" do

  before do
    @tmpdir = Dir.mktmpdir
    @wm = GollumCaves::WikiManager.new(@tmpdir)
    @wm.init()

    @wm.meta_wiki.commit_files(
      author: { :name => 'Felix', :email => 'felix@domain.tld' },
      message: "first change",
      files: {
        "foo.md" => "content of foo",
        "bar.md" => "content of bar",
        "x.png" => "this is a fake image",
      })
  end

  it "can get a wikifile object by filename" do
    wikifile = @wm.meta_wiki.wikifile('foo.md')
    expect(wikifile).to be_instance_of GollumCaves::WikiFile
    expect(wikifile.wiki).to be_instance_of GollumCaves::Wiki
  end
end
