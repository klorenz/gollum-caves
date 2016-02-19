require 'mustache'

class GollumCavesMustacheFilter < Mustache
  def command
  end
end

class GollumCavesMustacheFilterPre < GollumCavesMustacheFilter
  def puml
  end
end

class GollumCavesMustacheFilterPost < GollumCavesMustacheFilter
end


class Gollum::Filter::MustachePreProcessor < Gollum::Filter
  def extract(data)
    template = "{{=<< >>=}}\n#{data}"
    GollumCavesMustacheFilterPre.render template, @markup.metadata
  end

  def process(data)
    data
  end
end

class Gollum::Filter::MustachePostProcessor < Gollum::Filter
  def extract(data)
    data
  end

  def process(data)
    GollumCavesMustacheFilterPost.render data, @markup.metadata
  end
end
