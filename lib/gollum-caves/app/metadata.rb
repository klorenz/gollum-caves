require 'json'

module Precious
  class App
    get '/metadata/*' do
      path = params[:splat].first

      dir = File.dirname(path)
      ext = File.extname(path)
      name = File.basename(path, ext)

      wikifile = @wm.wikifile("#{dir}/#{name}")
      case ext
      when ".json"
        content_type :json
        wikifile.metadata.to_json
      else
        raise "Unknown output type"
      end
    end

    post '/metadata/*' do
      path = params[:splat].first
      message = nil
      if request.content_type == 'application/json'
        request.body.rewind
        data = JSON.parse request.body.read
      else
        message = params[:message]
        data = JSON.parse params[:data]
      end

      dir = File.dirname(path)
      ext = File.extname(path)
      name = File.basename(path, ext)

      if message.nil? or message.empty?
        message = "Update metadata (#{name})"
      end

      wikifile = @wm.wikifile("#{dir}/#{name}")

      wikifile.update_metadata(
        :author  => session['gollum.author'],
        :message => message,
        :metadata => data
      )
  end
end
