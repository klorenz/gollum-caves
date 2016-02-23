require 'rspec'

require File.expand_path '../../lib/gollum-caves/wiki_manager', __FILE__
require File.expand_path '../../lib/gollum-caves/wiki', __FILE__

describe "GollumCaves::WikiManager" do

  before do
    @tmpdir = Dir.mktmpdir
    @wm = GollumCaves::WikiManager.new(@tmpdir)
  end

  it "can create a collection" do
    @wm.create_collection("foo")
    expect(@wm.exists_collection?("foo")).to be true
    expect(@wm.exists_collection?("bar")).to be false
  end

  it "can create and access a wiki" do
    @wm = GollumCaves::WikiManager.new(@tmpdir)
    expect { @wm.create_wiki("foo", "bar") }.to raise_error("Collection foo does not exist.")
    expect(@wm.create_collection("foo")).to be_a(GollumCaves::Wiki)
    expect(@wm.create_wiki("foo", "bar")).to be_a(GollumCaves::Wiki)
    expect(@wm.exists? "foo/bar").to be true
    expect(@wm.wiki("foo/bar").exist?).to be true
  end

  it "can split wiki paths" do
    expect(@wm.split_wiki_path("/")).to eq ["wiki", "about", "/"]
    expect(@wm.split_wiki_path_wp("/")).to eq ["wiki/about", "/"]
    expect(@wm.split_wiki_path_wp("/foo")).to eq ["foo/about", "/"]
    expect(@wm.split_wiki_path_wp("/foo/bar")).to eq ["foo/bar", "/"]
    expect(@wm.split_wiki_path_wp("/foo/bar/glork")).to eq ["foo/bar", "glork"]
  end

  it "can commit files" do
    puts "test commit"
    @wm.init()

    puts "test committing files"
    @wm.meta_wiki.commit_files(
      author: { :name => 'Felix', :email => 'felix@domain.tld' },
      message: "first change",
      files: {
        "foo.md" => "content of foo",
        "bar.md" => "content of bar",
      })

    latest = @wm.meta_wiki.latest_commit
    puts "path: #{@wm.meta_wiki.path}"
    puts "latest: #{@wm.meta_wiki.latest_version}"

#    puts @wm.meta_wiki.tree_map_for(latest.first.id)
    # puts @wm.meta_wiki.file("foo.md")
    # puts @wm.meta_wiki.file("/foo.md")
    #@wm.meta_wiki

    expect(@wm.meta_wiki.wikifile("foo.md").raw_data).to eq "content of foo"
    expect(@wm.meta_wiki.wikifile("bar.md").raw_data).to eq "content of bar"

    ref = @wm.meta_wiki.latest_version

    @wm.meta_wiki.commit_files(
      author: { :name => 'Felix', :email => 'felix@domain.tld' },
      message: "second change",
      parent: ref,
      files: {
        "foo.md" => "content of foo 2",
      })

    expect(@wm.meta_wiki.file("foo.md").raw_data).to eq "content of foo 2"

    puts "_________________________________"

    expect{ @wm.meta_wiki.commit_files(
      author: { :name => 'Felix', :email => 'felix@domain.tld' },
      message: "second change",
      parent: ref,
      files: {
        "foo.md" => "content of foo 3",
        "bar.md" => "content of bar 3",
      }) }.to raise_error "repo has changed"

    @wm.meta_wiki.commit_files(
      author: { :name => 'Felix', :email => 'felix@domain.tld' },
      message: "second change",
      parent: ref,
      files: {
        "bar.md" => "content of bar 4",
      })

    expect(@wm.meta_wiki.file("bar.md").raw_data).to eq "content of bar 4"
  end

  describe "Tests on initialized wiki farm" do
    before do
      @wm.init()
    end

    it "can list collections" do
      expect(@wm.list_collections()).to eq [ "wiki", "wiki-plugins" ]
    end

    it "can list wikis" do
      expect(@wm.list_wikis('wiki')).to eq [ "about" ]
    end

  end

  after do
    FileUtils.remove_entry @tmpdir
  end

end
