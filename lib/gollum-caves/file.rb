require 'gollum-lib/file'

module Gollum
  # Gollum::Page compatibile Gollum::File
  #
  # Override Gollum::File and add some methods, to be Gollum::Page
  # compatible for editing e.g. image file formats
  class File
    def title
      name
    end

    def format
      ext = ::File.extname(name)
      puts "FORMAT: #{ext}"
      if ext == ".md"
        return :markdown
      else
        return ext[1..-1].to_sym
      end
    end

    def self.strip_filename(filename)
      ::File.basename(filename, ::File.extname(filename))
    end

    def filename_stripped
      self.class.strip_filename(filename)
    end
  end
end
