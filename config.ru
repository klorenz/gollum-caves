require 'rack'
require 'rubygems'
require 'gollum/app'
require 'json'


Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES

# limit to one format
Gollum::Page::FORMAT_NAMES = { :markdown => "Markdown" }

# require 'mustache/sinatra'


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

gollum_path = File.expand_path( ENV['WIKI_REPO'] || "#{File.dirname(__FILE__)}/wiki" )

Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {
    :mathjax => true,
    :live_preview => false,
    :universal_toc => true,
    :filter_chain =>
        # [:Metadata, :MustachePreProcessor, :PlainText, :TOC, :RemoteCode, :Code, :Macro, :MustachePostProcessor, :Sanitize, :Tags, :Render]
        [:Metadata, :PlainText, :TOC, :RemoteCode, :Code, :Macro, :Sanitize, :Tags, :Render],
#    :css => true,
    :bare => true,
    :template_dir => "templates",
})

require 'rack'


module Valuable
  class App < Precious::App
    def wiki_new
      puts "wiki_new: #{settings.gollum_path}, #{@wiki_collection}, #{@wiki_name}\n"

      Gollum::Wiki.new(::File.join(settings.gollum_path, @wiki_collection, "#{@wiki_name}.git"), settings.wiki_options)
    end

    def show_page_or_file(fullpath)
      wiki = wiki_new

      name = extract_name(fullpath) || wiki.index_page
      path = extract_path(fullpath) || '/'

      if page = wiki.paged(name, path, exact = true)
        @page          = page
        @name          = name
        @content       = page.formatted_data
        @source        = page.text_data
        @upload_dest   = find_upload_dest(path)

        # Extensions and layout data
        @editable      = true
        @page_exists   = !page.versions.empty?
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @mathjax       = wiki.mathjax
        @h1_title      = wiki.h1_title
        @bar_side      = wiki.bar_side
        @allow_uploads = wiki.allow_uploads

        mustache :page
      elsif file = wiki.file(fullpath, wiki.ref, true)
        show_file(file)
      else
        not_found unless @allow_editing
        page_path = [path, name].compact.join('/')
        redirect to("/#{@wiki_collection}/#{@wiki_name}/create/#{clean_url(encodeURIComponent(page_path))}")
      end
    end

    before do
      @wiki_base = 'wiki'
      @wiki_home = "home"
      @wiki_collection = @wiki_base
      @wiki_name = @wiki_home
    end

    get '/' do
      redirect clean_url(::File.join(@base_url, @wiki_base, @wiki_home, @page_dir, wiki_new.index_page))
    end

    before '/:coll/:name/*' do
      if params[:coll] != "javascript" and params[:coll] != "css"
        @wiki_collection = params[:coll]
        @wiki_name       = params[:name]
        request.path_info = "/#{params[:splat].first}"
      end
    end

    get '/data/*' do
      @wiki_collection = params[:coll]
      @wiki_name = params[:name]
      if page = wiki_page(params[:splat].first).page
        page.raw_data
      end
    end

    get '/javascript/ckeditor/*' do
      file_name = File.join(File.dirname(File.expand_path(__FILE__)), 'public', 'gollum', request.path_info)
      puts "filename: #{file_name}"
      send_file File.join(File.dirname(File.expand_path(__FILE__)), 'public', 'gollum', request.path_info)
    end
    get '/javascript/editor-plus.js' do
      file_name = File.join(File.dirname(File.expand_path(__FILE__)), 'public', 'gollum', request.path_info)
      puts "filename: #{file_name}"
      send_file File.join(File.dirname(File.expand_path(__FILE__)), 'public', 'gollum', request.path_info)
    end
    get '/javascript/markdown-editor/*' do
      file_name = File.join(File.dirname(File.expand_path(__FILE__)), 'public', 'gollum', request.path_info)
      puts "filename: #{file_name}"
      send_file File.join(File.dirname(File.expand_path(__FILE__)), 'public', 'gollum', request.path_info)
    end
  end
end

run Valuable::App
