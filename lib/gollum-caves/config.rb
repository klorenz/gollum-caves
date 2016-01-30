Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES

# limit to one format
Gollum::Page::FORMAT_NAMES = {
  :markdown => "Markdown"
}


# this is still original partial method, override this to search in
# multiple paths for name
class Mustache
  def partial(name)
    path = "#{template_path}/#{name}.#{template_extension}"

    # file does not exist, check if name is a variable containing a name,
    # which specifies another template
    #
    # <viewobject>.instance_variable_get("@#{name}")

    begin
      File.read(path)
    rescue
      raise if raise_on_context_miss?
      ""
    end
  end
end

# require 'mustache/sinatra'

# module Gollum
#   class Page
#     def settings_page
#       #if @
#   end
# end



require 'mustache'

class MarkdownMustache < Mustache
  def command
  end
end

class MarkdownMustachePre < MarkdownMustache
  def puml
  end
end

class MarkdownMustachePost < MarkdownMustache
end

require 'gollum-lib/filter'

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
      head = "<script>var METADATA = #{JSON.generate(@markup.metadata)}</script>\n"
    end
    head + data
  end
end

class Gollum::Filter::MustachePreProcessor < Gollum::Filter
    # embrace the code with {{=<< >>=}}
    # and process only <<#foo>> ... <</foo>> tags which are assumed to
    # produce markdown code.
    def extract(data)
      template = "{{=<< >>=}}\n#{data}"

      MarkdownMustachePre.render template, @markup.metadata
    end

    def process(data)
      data
    end

    # in this stage process {{...}} tags, which are assumed to produce
    # HTML
end

class Gollum::Filter::MustachePostProcessor < Gollum::Filter
    def extract(data)
        data
    end

    # in this stage process {{...}} tags, which are assumed to produce
    # HTML
    def process(data)
      MarkdownMustachePost.render data, @markup.metadata
    end
end

Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {
    :mathjax => true,
    :live_preview => false,
    # :universal_toc => true,
    :filter_chain =>
        # [:Metadata, :MustachePreProcessor, :PlainText, :TOC, :RemoteCode, :Code, :Macro, :MustachePostProcessor, :Sanitize, :Tags, :Render]
        #[:FrontMatter, :Metadata, :PlainText, :GollumCavesPlugins, :TOC, :RemoteCode, :Code, :Macro, :Sanitize, :Tags, :Render],
        #[:FrontMatter, :MustachePreProcessor, :PlainText, :TOC, :RemoteCode, :Code, :Macro, :MustachePostProcessor, :Sanitize, :Tags, :Render],
        [:FrontMatter, :MustachePreProcessor, :PlainText, :TOC, :RemoteCode, :Code, :Macro, :MustachePostProcessor, :Tags, :Render],

#    :css => true,
    :repo_is_bare => false,
    :template_dir => "templates",
    :allow_uploads => true,
    :per_page_uploads => true
})

require 'gollum-caves/bootstrap'
