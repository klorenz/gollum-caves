require 'gollum/views/pages'

module Precious
  module Views
    class Pages
      def wikipath
        @wikipath
      end

      def breadcrumb
        if @path
          path       = Pathname.new(@path)
          breadcrumb = [%{<a href="#{@base_url}/pages/#{@wikipath}/">Home</a>}]
          path.descend do |crumb|
            title = crumb.basename

            if title == path.basename
              breadcrumb << title
            else
              breadcrumb << %{<a href="#{@base_url}/pages/#{@wikipath}/#{crumb}/">#{title}</a>}
            end
          end

          breadcrumb.join(" / ")
        else
          "Home"
        end
      end

      def files_folders
        if has_results
          folders = {}
          page_files = {}

          # 1012: Folders and Pages need to be separated
          @results.each do |page|
            page_path = page.path.sub(/^#{@path}\//, '')

            if page_path.include?('/')
              folder      = page_path.split('/').first
              folder_path = @path ? "#{@path}/#{folder}" : folder
              folder_link = %{<li><a href="#{@base_url}/pages/#{@wikipath}/#{folder_path}/" class="folder">#{folder}</a></li>}

              folders[folder] = folder_link unless folders.key?(folder)
            elsif page_path != ".gitkeep"
              if defined? page.format
                page_link = %{<li><a href="#{@base_url}/#{@wikipath}/#{page.escaped_url_path}" class="file">#{page.name}</a></li>}
                page_files[page.name] = page_link
              else
                page_link = %{<li><a href="#{@base_url}/#{@wikipath}/#{page.escaped_url_path}#{page.name}" class="file">#{page.name}</a></li>}
                page_files[page.name] = page_link
              end
            end
          end

          # 1012: All Pages should be rendered as Folders first, then Pages, each sorted alphabetically
          result = Hash[folders.sort_by{| key, value | key.downcase} ].values.join("\n") + "\n"
          result += Hash[page_files.sort_by{ | key, value | key.downcase } ].values.join("\n")

          result
        else
          ""
        end
      end

    end
  end
end
