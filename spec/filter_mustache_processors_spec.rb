require "rspec"
require File.expand_path "../../lib/gollum-caves/filter/mustache_processors.rb", __FILE__

describe "Mustache Filters" do
  it "can preprocess data" do
    markup = Gollum::Markup.new(nil)
    markup.metadata = {
      'key' => 'value'
    }

    preprocessor = Gollum::Filter::MustachePreProcessor.new(markup)
    expect(preprocessor.extract("<<key>>")).to eq("value")
  end

  it "can postprocess data" do
    markup = Gollum::Markup.new(nil)
    markup.metadata = {
      'key' => 'value'
    }
    preprocessor = Gollum::Filter::MustachePostProcessor.new(markup)
    expect(preprocessor.process("{{key}}")).to eq("value")
  end
end
