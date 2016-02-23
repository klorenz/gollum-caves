require 'rspec'

require File.expand_path '../../lib/gollum-caves/filter/process_headlines.rb', __FILE__

describe "process_headlines Filter" do
  it "leaves input data unprocessed" do
    markup = Gollum::Markup.new(nil)
    process_headlines = Gollum::Filter::ProcessHeadlines.new(markup)

    expect(process_headlines.extract("foo")).to eq "foo"
  end

  it "extracts sections from html data" do
    markup = Gollum::Markup.new(nil)
    process_headlines = Gollum::Filter::ProcessHeadlines.new(markup)

    expect(process_headlines.process("<h1>h1</h1><p>some text</p><h2>headline on 2nd <b>level</b></h2>")).to eq(
      %{<h1 id="h1">h1</h1><p>some text</p><h2 id="headline-on-2nd-level">headline on 2nd <b>level</b>\n</h2>})

    expected = {
      "h1" => {:section=>"h1", :level=>1, :id=>"h1", :number=>1},
      "headline-on-2nd-level" => {:section=>"headline on 2nd level", :level=>2, :id=>"headline-on-2nd-level", :number=>2},
    }
    expect(markup.metadata['sections']).to eq expected
  end
end
