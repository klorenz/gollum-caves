module Precious
  class App
    get '/create/*' do
      forbid unless @allow_editing
      @filename = Gollum::Page.cname(params[:splat].first)

      wikifile = @wm.wikifile(@filename)
      if not wikifile.nil?
        redirect to("/view/#{@filename}")
      else
        @name = Gollum::Page.strip_filename(@filename)
        @format = params[:format].to_s
        @redirect_url = params[:redirect_url].to_s
        wn, cn, @path = @wm.split_wiki_path @filename
        @path = File.dirname(@path).sub(/^\./, '')

        @wiki = @wm.wiki(wn, cn)

        if @format.empty?
          @format = Gollum::Page.format_for(@filename)
          if @format.nil?
            @format = ::File.extname(@filename)[1..-1].to_s
            if @format.empty?
              @format = :markdown  # default format
            end
          end
        end

        if @redirect_url.empty?
          @redirect_url = request.referer
        end

        @editor = GollumCaves::WikiFile.editor_for(@format)
        @allow_uploads = @wiki.allow_uploads
        @upload_dest   = find_upload_dest(@path)

        mustache :create
      end
    end


    post '/create' do
      name   = params[:page]
      path   = sanitize_empty_params(params[:path]) || ''
      format = params[:format].to_s.to_sym
      wikipath = params[:wikipath].to_s

      @redirect_url = params[:redirect_url]

      log_debug("create: name=#{name}, path=#{path}, format=#{format}, wikipath=#{wikipath}")

      # convert title to pagename
      name = Gollum::Page.cname(name)

      # add extension by format, if not given
      ext = ::File.extname(name)
      if ext.empty?
        ext = "."+settings.gollum_caves[:format_exts][format].to_s
        name = "#{name}#{ext}"
      end

      # have full name
      fullname = "#{path}/#{name}#{ext}"

      # get the wiki
      wiki = @wm.wiki(wikipath)

      # try to get the file
      wikifile = wiki.wikifile(fullname)

      # store if not yet exists
      if wikifile.nil?
        begin
          wiki.commit_files(
            author: session['gollum.author'],
            message: params[:message],
            # parent:
            files: {
              fullname => params[:content]
            }
          )

          redirect to clean_path "/view/#{wikipath}/#{fullname}"

        rescue Gollum::DuplicatePageError => e
          @message = "Duplicate page: #{e.message}"
          mustache :error
        end
      end
    end

  end
end
