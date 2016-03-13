require 'gollum-caves/wiki_manager'

module Precious
  class App
    def show_page_or_file2(fullpath)
      log_debug("show_page_or_file: #{fullpath}")

      begin
        wikifile = @wm.wikifile(fullpath)
      rescue
        log_error "error getting wikifile #{fullpath}"
      end
      log_debug("wikifile: #{wikifile}")
      log_debug("wiki_1: #{@wiki}")

      @wiki = wikifile.wiki

      if wikifile.nil?
        if fullpath[0] == '/'
          fullpath = fullpath[1..-1]
        end
        redirect to("/create/#{fullpath}")

      elsif page = wikifile.as_page
        @page = page
        @name = page.name
        @content = page.formatted_data
        @source  = page.text_data
        @upload_dest = find_upload_dest(wikifile.path)
        @editable    = true
        @page_exists = true
        @mathjax     = wikifile.wiki.mathjax
        @h1_title      = wikifile.wiki.h1_title
        @bar_side      = wikifile.wiki.bar_side
        @allow_uploads = wikifile.wiki.allow_uploads
        @attachments   = []
        log_debug("page.path: #{page.path}")
        @has_attachments = !@attachments.empty?
        @filename = wikifile.filename

        log_debug("wiki_2: #{@wiki}")
        mustache :page
      else
        show_file wikifile.as_file
      end
    end

    # Public: show a Gollum::File object
    def show_file(file)
      return unless file
      if file.on_disk?
        send_file file.on_disk_path, :disposition => 'inline'
      else
        content_type file.mime_type
        file.raw_data
      end
    end

    # # Set defaults for wiki farm
    # before do
    #   default = ENV['WIKI_DEFAULT']
    #
    #   if not default.nil?
    #     @wiki_base, @wiki_home = default.split('/')
    #   else
    #     @wiki_base = 'wiki'
    #     @wiki_home = "me"
    #   end
    #
    #   @wiki_collection = @wiki_base
    #   @wiki_name = @wiki_home
    #
    #   # values from kj
    #
    # end
  end
end
