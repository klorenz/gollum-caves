module Precious
  class App
    def search(coll, wiki)
      @query = params[:q] || term
      @results = @wm.search @user, @query, nil, nil
      @name = @query
      mustache :search
    end

    get '/search' do
      search nil, nil
    end

    get '/search/:coll' do
      search params[:coll], nil
    end

    get '/search/:coll/:wiki' do
      search params[:coll], params[:wiki]
    end

  end
end
