module Precious
  class App

    # TODO:60 Sort out history of global, coll, wiki, file
    #
    # - file is easy and current case
    # - wiki means same as latest_changes
    # - coll means mix history of all wikis together
    # - global means mix history of everything
    #
    get '/history/*' do
      wikifile = @wm.wikifile(params[:splat].first)
      @page = wikifile

      @page_num = [params[:page].to_i, 1].max
      unless @pae.nil?
        @versions = @wikifile.versions :page => @page_num
        mustache :history
      else
        redirect to("/")
      end
    end

    get '/latest_changes/*' do
      wikifile
    end
  end
end
