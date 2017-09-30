require 'json'

module Dropbox
  module API

    class Client

      module Files

        def download(path, options = {})
          path     = path
          url      = ['', "files", "download"].compact.join('/')
          api_args = { path: path }
          connection.get_raw(:content, url, nil, {
            "Dropbox-API-Arg" => ::JSON.dump(api_args)
          })
        end

        def upload(path, data, options = {})
          url      = ['', "files", "upload"].compact.join('/')
          api_args = { path: path, mode: "overwrite" }.merge(options)
          response = connection.post_raw(:content, url, data, {
            'Content-Type'    => "application/octet-stream",
            "Content-Length"  => data.length.to_s,
            "Dropbox-API-Arg" => ::JSON.dump(api_args)
          })
          Dropbox::API::File.new(response, self)
        end

        def chunked_upload(path, file, options = {})

          total_file_size = ::File.size(file)
          chunk_size      = options[:chunk_size] || 4*1024*1024 # default 4 MB chunk size
          offset          = options[:offset] || 0
          session_id      = nil
          api_args        = { path: path, mode: 'overwrite' }.merge(options)

          while offset < total_file_size
            data = file.read chunk_size

            puts "path: #{path} / offset: #{offset} / len #{data.length} / tot: #{total_file_size}"
            if (offset.zero?)
              response = connection.post :content,
                '/files/upload_session/start', data,
                'Content-Type'   => "application/octet-stream",
                "Content-Length" => data.length.to_s
              session_id = response['session_id']
            else
              attrs = {
                cursor: {
                  offset: offset,
                  session_id: session_id
                }
              }
              query    = Dropbox::API::Util.query options.merge(attrs)
              response = connection.post :content,
                '/files/upload_session/append_v2', data,
                'Content-Type'   => "application/octet-stream",
                "Content-Length" => data.length.to_s,
                "Dropbox-API-Arg" => ::JSON.dump(attrs)
            end
            offset = offset + (data.length-1)
          end


          attrs = {
            cursor: {
              offset: offset,
              session_id: session_id
            }
          }
          root     = options.delete(:root) || Dropbox::API::Config.mode
          commit_url = ['', "files/upload_session/finish", root, path].compact.join('/')
          response = connection.post :content, commit_url, "", {
            'Content-Type'   => "application/octet-stream",
            "Content-Length" => "0",
            "Dropbox-API-Arg" => ::JSON.dump(attrs)
          }

          Dropbox::API::File.new(response, self)
        end

        def copy_from_copy_ref(copy_ref, to, options = {})
          raw.copy({
            :from_copy_ref => copy_ref,
            :to_path => to
          }.merge(options))
        end

      end

    end

  end
end
