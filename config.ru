require 'rack'
require 'rubygems'
require 'gollum/app'
require 'json'

require 'gollum/views/create'

module Precious
  module Views
    class Create
      def editor_markdown
        @editor_markdown
      end
      def editor_source
        @editor_source
      end
      def editor_svg
        @editor_svg
      end
    end
  end
end


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

    get '/gollum-caves/css/*' do
      file_name = File.join(File.dirname(File.expand_path(__FILE__)), 'public', request.path_info)
      send_file file_name
    end

    get '/gollum-caves/javascript/*' do
      file_name = File.join(File.dirname(File.expand_path(__FILE__)), 'public', request.path_info)
      send_file file_name
    end

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

    # Set defaults for wiki farm
    before do
      @wiki_base = 'wiki'
      @wiki_home = "home"
      @wiki_collection = @wiki_base
      @wiki_name = @wiki_home
      @wiki_url = clean_url(::File.join(@base_url, @wiki_collection, @wiki_name))
    end

    get '/' do
      redirect clean_url(::File.join(@base_url, @wiki_base, @wiki_home, @page_dir, wiki_new.index_page))
    end

    # get wikifarm information /<collection>/<name> and melt down path_info
    before '/:coll/:name/*' do
      if params[:coll] != "javascript" and params[:coll] != "css" and params[:coll] != "gollum-caves"
        @wiki_collection = params[:coll]
        @wiki_name       = params[:name]
        @wiki_url = clean_url(::File.join(@base_url, @wiki_collection, @wiki_name))
        request.path_info = "/#{params[:splat].first}"
      end
    end

    get '/data/*' do
      @wiki_collection = params[:coll]
      @wiki_name = params[:name]
      @page_name = params[:splat].first

      #if @page_name.match(/\.json$/)
        # return a json with additional info about page
      if page = wiki_page(params[:splat].first).page
        page.raw_data
      end
    end

    get '/edit/*' do
      forbid unless @allow_editing
      wikip = wiki_page(params[:splat].first)
      @name = wikip.name
      @path = wikip.path
      @upload_dest   = find_upload_dest(@path)

      ext = ::File.extname(@name)

      if not ext
        ext = ".md"
        @name = "#{name}#{ext}"
      end

      @editor_markdown = false
      @editor_svg      = false
      @editor_source   = false
      @editor_upload   = false

      if ext == ".md"
        @editor_markdown = true
      elsif ext == ".svg"
        @editor_svg = true
      # if is textfile
      elsif wikip.name.match(/\.(txt|rst|css|less|js|coffee|c|cpp|cxx|h|hpp|hxx)$/)
        @editor_source = true
      else
        @editor_upload = true
      end

      puts "edit name #{@name}, path #{@path}, ext #{ext}, editor_markdown: #{@editor_markdown}"

      wiki = wikip.wiki
      @allow_uploads = wiki.allow_uploads
      if page = wikip.page
        @page         = page
        @page.version = wiki.repo.log(wiki.ref, @page.path).first
        @content      = page.text_data
        mustache :edit
      else
        redirect to("/create/#{encodeURIComponent(@name)}")
      end
    end

    get '/create/*' do
      forbid unless @allow_editing
      name = params[:splat].first.gsub('+', '-')
      wikip = wiki_page(name)
      @name = wikip.name.to_url

      ext = ::File.extname(name)
      if ext == ""
        ext  = ".md"
        wikip = wiki_page("#{name}.md")
      end

      @path = wikip.path

      @editor_markdown = false
      @editor_svg      = false
      @editor_source   = false
      @editor_upload   = false

      if ext == ".md"
        @editor_markdown = true
      elsif ext == ".svg"
        @editor_svg = true
      # if is textfile
      elsif wikip.name.match(/\.(txt|rst|css|less|js|coffee|c|cpp|cxx|h|hpp|hxx)$/)
        @editor_source = true
      else
        @editor_upload = true
      end

      puts "create name #{@name}, path #{@path}, ext #{ext}, editor_markdown: #{@editor_markdown}"
      @allow_uploads = wikip.wiki.allow_uploads
      @upload_dest   = find_upload_dest(@path)

      page_dir = settings.wiki_options[:page_file_dir].to_s
      unless page_dir.empty?
        # --page-file-dir docs
        # /docs/Home should be created in /Home
        # not /docs/Home because write_page will append /docs
        @path = @path.sub(page_dir, '/') if @path.start_with? page_dir
      end
      @path = clean_path(@path)

      @foo = "bar"

      page = wikip.page
      if page
        page_dir = settings.wiki_options[:page_file_dir].to_s
        redirect to("/#{clean_url(::File.join(page_dir, page.escaped_url_path))}")
      else
        mustache :create
      end
    end


    post '/create' do
      name   = params[:page].to_url
      path   = sanitize_empty_params(params[:path]) || ''
      #format = params[:format].intern
      wiki   = wiki_new

      path.gsub!(/^\//, '')
      ext = ::File.extname(name)

      if ext == ""
        ext = "md"
        name = "#{name}.#{ext}"
        format = :markdown
      else
        format = ext
      end

      begin
        wiki.write_page(name, format, params[:content], commit_message, path)

        page_dir = settings.wiki_options[:page_file_dir].to_s
        redirect to("/#{clean_url(::File.join(page_dir, path, encodeURIComponent(name)))}")
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

  end
end

run Valuable::App
