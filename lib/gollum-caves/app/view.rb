module Precious
  class App
    get '/view/*' do
      show_page_or_file2(params[:splat].first)
    end
  end
end
