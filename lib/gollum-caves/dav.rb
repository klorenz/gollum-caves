require 'rack_dav/resource'

# See https://github.com/georgi/rack_dav/blob/master/lib/rack_dav/file_resource.rb

module GollumCaves

  class GitDavResource < RackDAV::Resource

    def children
      wiki_dir_entries.each do |entry|
        child entry
      end
    end

    def collection?
      wiki_folders.has_key?(file_path)
    end

    def exists?
      wiki_folders.has_key?(file_path) or wiki_entries.has_key?(file_path)
    end

    def creation_date
      # get the first entry from the log and extract the date
      wiki.file
    end

    def last_modified
      # get the latest change of file and extract the date
    end

    # Set the time of last modification
    def last_modified=(time)
      # this is not possible with git
    end

    # Return an Etag, an unique hash value for this resource
    def etag
      # take the version number and hash of filename
    end

    def resource_type
      if collection?
        Nokogiri::XML::fragment('<D:collection xmlns:D="DAV:"/>').children.first
      end
    end

    def content_length
      # return size of the blob
    end

    def set_custom_property(name, value)
      # this is not possible (for now)
    end

    def get_custom_property(name)
      raise HTTPStatus::NotFound
      # this is not possible (for now)
    end

    def list_custom_properties
      []
    end

    # HTTP GET request
    def get
      puts "file_path #{file_path}"
      if collection?
        content = ""
        wiki_dir_entries.each { |entry| content << entry }
        @response.body = [content]
        @response['Content-Length'] = (content.respond_to?(:bytesize) ? content.bytesize : content.size).to_s
      else
        @response.body = wiki.file(file_path).raw_data
      end
    end

    def put
      if @request.env['HTTP_CONTENT_MD5']
        content_md5_pass?(@request.env) or raise HTTPStatus::BadRequest.new('Content-MD5 mismatch')
      end
      write(@request.body)
    end

    def post
      raise HTTPStatus::Forbidden
    end

    def delete
      raise HTTPStatus::Forbidden
      # if collection?
      # else
      # end
    end

    def copy(dest)
      raise HTTPStatus::Forbidden
    end

    def move(dest)
      raise HTTPStatus::Forbidden
    end

    def make_collection
      # file_path
      raise HTTPStatus::Forbidden
    end

    def write
      # commit file to repo
    end

    def file_path
      _path = path.gsub(/^\/+/, '')
      _path.split('/', 3)[2]
    end

    def wiki
      _path = path.gsub(/^\/+/, '')
      _coll, _wiki, _file_path = _path.split('/', 3)

      if @options[:repo_is_bare]
        _wiki = "#{_wiki}.git"
      end

      repo_path = ::File.join(@options[:gollum_path], _coll, _wiki)
      Gollum::Wiki.new(repo_path)
    end

    def wiki_files
      _wiki = wiki
      # all wiki entries
      files = _wiki.pages
      files += _wiki.files
      files.sort_by { |f| f.name.downcase }
    end

    def wiki_dir_entries
      # find folders and files
      folders = {}
      files = {}

      wiki_files.each do |file|
        fpath = file.path.sub(/^#{file_path}\//, '')
        if fpath.include?('/')
          folder = fpath.split('/').first
          folders[folder] = "#{file_path}/#{folder}"
        else
          files[fpath] = "#{file_path}/#{fpath}"
        end
      end

      # create result from folders and files
      result = Hash[folders.sort_by{|k,v| k.downcase}].keys
      result += Hash[files.sort_by{|k,v| k.downcase}].keys

      result
    end

    def wiki_folders
      folders = {}
      wiki_entries.each do |file|
        if file.match(/^(.*)\//)
          folders[Regexp.last_match[1]] = true
        end
      end
      folders
    end

  end

end
