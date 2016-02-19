require 'nokogiri'
require 'gollum-lib/filter'

class Gollum::Filter::ProcessHeadlines < Gollum::Filter

  def extract(data)
    data
  end

  def process(rendered_data)
    @markup.metadata ||= {}
    @markup.metadata['sections'] = sections = {}
    # @document_info['links']    = links = {}
    doc = Nokogiri::HTML::DocumentFragment.parse(rendered_data)
    number = 0
    doc.traverse do |node|
      if node.name.match(/^[hH]([1-6])$/)
        level = Regexp.last_match[1].to_i
        id = node.text.downcase.gsub(/(\W+)/, '-')
        number += 1
        if sections.has_key?(id)
          i = 1
          while sections.has_key?("#{id}-#{i}") do
            i += 1
          end
          id = "#{id}-#{i}"
        end
        sections[id] = {
          :section => node.text,
          :level   => level,
          :id      => id,
          :number  => number,
        }
        node['id'] = id
      end
    end
    doc.to_html
  end
end
