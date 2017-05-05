require 'json'

module Dropbox
  module API

    class Client

      module Files

        def download(path, options = {})
          path     = Dropbox::API::Util.escape(path)
          url      = ['', "files", "download"].compact.join('/')
          api_args = { :path => path }
          connection.get_raw(:content, url, nil, {
            "Dropbox-API-Arg" => ::JSON.dump(api_args)
          })
        end

        def upload(path, data, options = {})
          url      = ['', "files", "upload"].compact.join('/')
          api_args = { :path => path, :mode => "overwrite" }.merge(options)
          response = connection.post_raw(:content, url, data, {
            'Content-Type'    => "application/octet-stream",
            "Content-Length"  => data.length.to_s,
            "Dropbox-API-Arg" => ::JSON.dump(api_args)
          })
          Dropbox::API::File.init(response, self)
        end

        def chunked_upload(path, file, options = {})
          root     = options.delete(:root) || Dropbox::API::Config.mode
          path     = Dropbox::API::Util.escape(path)
          upload_url = '/chunked_upload'
          commit_url = ['', "commit_chunked_upload", root, path].compact.join('/')

          total_file_size = ::File.size(file)
          chunk_size = options[:chunk_size] || 4*1024*1024 # default 4 MB chunk size
          offset = options[:offset] || 0
          upload_id = options[:upload_id]

          while offset < total_file_size
            data = file.read(chunk_size)

            query    = Dropbox::API::Util.query(options.merge(:offset => offset))
            response = connection.put(:content, "#{upload_url}?#{query}", data, {
              'Content-Type'   => "application/octet-stream",
              "Content-Length" => data.length.to_s
            })

            upload = Dropbox::API::Object.init(response, self)
            options[:upload_id] ||= upload[:upload_id]
            offset += upload[:offset].to_i - offset if upload[:offset] && upload[:offset].to_i > offset
            yield offset, upload if block_given?
          end


          query = Dropbox::API::Util.query({:upload_id => options[:upload_id]})

          response = connection.post(:content, "#{commit_url}?#{query}", "", {
            'Content-Type'   => "application/octet-stream",
            "Content-Length" => "0"
          })

          Dropbox::API::File.init(response, self)
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
