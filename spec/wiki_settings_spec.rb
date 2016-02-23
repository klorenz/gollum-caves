require 'rspec'

require File.expand_path '../../lib/gollum-caves/wiki_manager.rb', __FILE__
require File.expand_path '../../lib/gollum-caves/deep_merge.rb', __FILE__


describe "Hash::deeper_merge" do
  it "can merge hashes and arrays deeply" do
    hash1 = {
      :foo => [ 1, 2],
      :glork => {
        "first" => "value1",
        "second" => "value2",
      }
    }

    hash2 = {
      :foo => [ 2, 3],
      :bar => "hello",
      :glork => {
        "third" => "value2",
      }
    }

    expected = {
      :foo => [ 1, 2, 3],
      :bar => "hello",
      :glork => {
        "first" => "value1",
        "second" => "value2",
        "third" => "value2"
      }
    }

    expect(hash1.deeper_merge hash2).to eq expected
  end
end

describe "Hash::deep_merge" do
  it "can merge hashes deeply" do
    hash1 = {
      :foo => [ 1, 2],
      :glork => {
        "first" => "value1",
        "second" => "value2",
      }
    }

    hash2 = {
      :foo => [ 2, 3],
      :bar => "hello",
      :glork => {
        "third" => "value2",
      }
    }

    expected = {
      :foo => [ 2, 3],
      :bar => "hello",
      :glork => {
        "first" => "value1",
        "second" => "value2",
        "third" => "value2"
      }
    }

    expect(hash1.deep_merge hash2).to eq expected
  end
end

describe "GollumCaves::WikiSettings" do
  before do
    @tmpdir = Dir.mktmpdir
    @wm = GollumCaves::WikiManager.new(@tmpdir) @wm.init() @coll = "user" @wiki = "felix"
    @wm.create_collection(@coll)
    @wm.create_wiki(@coll, @wiki)
  end

  it "can write and read settings" do
    settings = {
      "foo" => "bar",
      "number" => 1,
    }
    @wm.settings.write(@wm.meta_wiki,
      settings: settings,
      author: { :name => "Alice", :email => "alice@wonderland.org" },
      message: "a commit"
      )
    expect(@wm.settings.read(@wm.meta_wiki)).to eq settings
  end

  it "can read merged settings" do
    meta_settings = {
      "foo" => "bar",
      "number" => 1,
    }

    coll_settings = {
      "foo" => "glork",
      "list" => [ "first", "second" ]
    }

    wiki_settings = {
      "list" => [ "third" ]
    }

    @wm.settings.write(@wm.meta_wiki,
      settings: meta_settings,
      author: { :name => "Alice", :email => "alice@wonderland.org" },
      message: "a commit"
      )

    @wm.settings.write(@wm.wiki(@coll),
      settings: coll_settings,
      author: { :name => "Alice", :email => "alice@wonderland.org", message: "update settings" },
      message: "a commit"
      )
    @wm.settings.write(@wm.wiki(@coll, @wiki),
      settings: wiki_settings,
      author: { :name => "Alice", :email => "alice@wonderland.org", message: "update settings" },
      message: "a commit"
      )

    expected_settings = {
      "foo" => "glork",
      "list" => ["third"],
      "number" => 1
    }

    expect(@wm.settings.get(@coll, @wiki)).to eq expected_settings
  end


  it "can write settings" do
    @wm.settings.write(@wm.meta_wiki,
      settings: {
        "foo" => "bar",
        "number" => 1,
      },
      author: { :name => "Alice", :email => "alice@wonderland.org"},
      message: "update settings",
    )
  end

  after do
    # FileUtils.remove_entry @tmpdir
    puts @tmpdir
  end

end
