require "dropbox-api/client/raw"
require "dropbox-api/client/files"

module Dropbox
  module API

    class Client

      attr_accessor :raw,
                    :connection

      def initialize(options = {})
        @connection = Dropbox::API::Connection.new(token: options.delete(:token))
        @raw        = Dropbox::API::Raw.new connection: @connection
        @options    = options
      end

      include Dropbox::API::Client::Files

      def find(filename)
        data = self.raw.metadata(path: filename)
        Dropbox::API::Object.convert(data, self)
      end

      def ls(path='')
        Dropbox::API::Dir.new({path: path}, self).ls
      end

      def continue(cursor)
        Dropbox::API::Dir.new({}, self).continue(cursor)
      end

      def ls_all(path='')
        Dropbox::API::Dir.new({path: path}, self).ls_all
      end

      def account
        Dropbox::API::Account.new(self.raw.account, self)
      end

      def mkdir(path)
        # Remove the characters not allowed by Dropbox
        path = path.gsub(/[\\\:\?\*\<\>\"\|]+/, '')
        response = raw.create_folder :path => path
        Dropbox::API::Dir.new(response, self)
      end

      def destroy(path, options = {})
        response = raw.delete({ :path => path }.merge(options))
        Dropbox::API::Object.convert(response, self)
      end

      def search(term, options = {})
        options[:path] ||= ''
        results = raw.search({query: term}.merge(options))
        res = Dropbox::API::Object.convert results, self
        if res.is_a?(Dropbox::API::File)
          [res]
        else
          res
        end
      end

      def delta(cursor=nil, options={})
        entries  = []
        has_more = true
        params   = cursor ? options.merge(recursive: true, cursor: cursor) : options
        while has_more
          response        = raw.ls(params)
          params[:cursor] = response['cursor']
          has_more        = response['has_more']
          entries.push     *response['entries']
        end

        files = entries.map do |entry|
          entry.last || {:is_deleted => true, :path => entry.first}
        end

        Delta.new(params[:cursor], Dropbox::API::Object.convert(files, self))
      end

    end

  end
end
