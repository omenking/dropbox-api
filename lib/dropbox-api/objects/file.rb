module Dropbox
  module API

    class File < Dropbox::API::Object

      include Dropbox::API::Fileops

      def revisions(options = {})
        response = client.raw.revisions({ :path => self.path }.merge(options))
        Dropbox::API::Object.convert(response["entries"], client)
      end

      def restore(rev, options = {})
        response = client.raw.restore({ :rev => rev, :path => self.path }.merge(options))
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
        response = client.raw.copy_ref({ :path => self.path }.merge(options))
        Dropbox::API::Object.init(response, client)
      end

      def download
        client.download(self.path)
      end

      def direct_url(options = {})
        response = client.raw.media({ :path => self.path }.merge(options))
        Dropbox::API::Object.init(response, client)
      end

    end

  end
end
