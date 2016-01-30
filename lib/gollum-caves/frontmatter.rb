module GollumCaves
  module Frontmatter
    # mixin for extracting frontmatter from file
    def get_frontmatter(data)
      if data.match(/\A---\n([\s\S]*?\n)---\n/)
        log_debug "matched '#{Regexp.last_match[1]}'"
        YAML.load(Regexp.last_match[1])
      else
        {}
      end
    end

    # do something with frontmatter and return the page without frontmatter
    def with_frontmatter(data, &block)
      data.gsub(/\A---\n([\s\S]*?\n)---\n/) do
        log_debug "with_fm matched '#{Regexp.last_match[1]}'"
        block.call YAML.load(Regexp.last_match[1])
      end
    end

    def set_frontmatter(hash, data)
      data.gsub(/\A(---\n([\s\S]*?\n)---(\Z|\n\n?))?/) do
        log_debug "data: '#{data}'"
        log_debug "set_fm matched '#{Regexp.last_match[1]}'"
        if hash.empty?
          ""
        else
          "#{YAML.dump(hash)}---\n\n"
        end
      end
    end
  end
end
