require 'rspec'

require File.expand_path '../../lib/gollum-caves/frontmatter', __FILE__
require File.expand_path '../../lib/gollum-caves/logging', __FILE__

class FrontmatterContainer
  include GollumCaves::Logging
  include GollumCaves::Frontmatter
end

describe "Frontmatter Mixin" do
  before do
    @fm = FrontmatterContainer.new()
  end

  it "can parse frontmatter" do
    data = @fm.get_frontmatter(
      "---\n"\
      "hello: world\n"\
      "---\n"\
      "\n"\
      "And here is the text.\n"
    )

    expect(data['hello']).to eq "world"
  end
  it "can set frontmatter" do
    data = @fm.set_frontmatter({
      "hello" => "new world"
    },
    "---\n"\
    "hello: world\n"\
    "---\n"\
    "\n"\
    "And here is the text.\n"
    )

    expect(data).to eq "---\n"\
    "hello: new world\n"\
    "---\n"\
    "\n"\
    "And here is the text.\n"

  end
end
