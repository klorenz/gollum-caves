
class Gollum::Filter::FrontMatter < Gollum::Filter
  def extract(data)
    data.gsub(/^---\n(.*?\n)---\n/) do
      @markup.metadata ||= {}
      @markup.metadata = @markup.metadata.merge(YAML.load(Regexp.last_match[1]))
    end

    # data.gsub(/^```-yaml\n(.*)^```\n/m) do
    #   @markup.metadata ||= {}
    #   @markup.metadata = @markup.metadata.merge(YAML.load(Regexp.last_match[2]))
    #   ''
    # end
  end

  def process(data)
    head = ""
    if @markup.metadata
      head = "<script>var FRONTMATTER = #{JSON.generate(@markup.metadata)}</script>\n"
    end
    head + data
  end
end
