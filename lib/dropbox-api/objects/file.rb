module Dropbox
  module API

    class File < Dropbox::API::Object
      # {
      #    "name"=>"spec-find-file-test-1506706265.txt",
      #    "path_lower"=>"/test-1506706265/spec-find-file-test-1506706265.txt",
      #    "path_display"=>"/test-1506706265/spec-find-file-test-1506706265.txt",
      #    "id"=>"id:UcOSbd2F8u4AAAAAAAABJg",
      #    "client_modified"=>"2017-09-29T17:31:06Z",
      #    "server_modified"=>"2017-09-29T17:31:06Z",
      #    "rev"=>"13b10e4d5a28",
      #    "size"=>9,
      #    "content_hash"=>"6ca075c3950af5ffff4e6c471898ae75f95c87334083478aadd7bbb92bdc1390"
      # }
      attr_accessor :name,
                    :path_lower,
                    :path_display,
                    :path,
                    :id,
                    :client_modified,
                    :server_modified,
                    :rev,
                    :size,
                    :content_hash
      def initialize response, client
        self.update response
        super
      end

      include Dropbox::API::Fileops

      def update response
        self.name            = response['name']
        self.path_lower      = response['path_lower']
        self.path_display    = response['path_display']
        self.path            = response['path_display']
        self.id              = response['id']
        self.client_modified = response['client_modified']
        self.server_modified = response['server_modified']
        self.rev             = response['rev']
        self.size            = response['size']
        self.content_hash    = response['content_hash']
      end

      def revisions(options = {})
        response = client.raw.revisions({ path: self.path }.merge(options))
        Dropbox::API::Object.convert(response["entries"], client)
      end

      def restore(rev, options = {})
        response = client.raw.restore({ rev: rev, path: self.path }.merge(options))
        self.update response
      end

      def thumbnail(options = {})
        path     = Dropbox::API::Util.escape(self.path)
        url      = ['', "files", "get_thumbnail"].compact.join('/')
        api_args = { :path => path }.merge(options)
        client.connection.get_raw(:content, url, nil, {
          "Dropbox-API-Arg" => ::JSON.dump(api_args)
        })
      end

      def copy_ref(options = {})
        response = client.raw.copy_ref({ path: self.path }.merge(options))
        Dropbox::API::Object.new(response, client)
      end

      def download
        client.download(self.path)
      end

      def direct_url(options = {})
        response = client.raw.media({ path: self.path }.merge(options))
        Dropbox::API::Object.new(response, client)
      end

    end

  end
end
