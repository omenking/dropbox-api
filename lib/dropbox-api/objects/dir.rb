require 'pry'
module Dropbox
  module API
    class Dir < Dropbox::API::Object
      # {
      #  "name"=>"spec-find-dir-test-1506711856",
      #  "path_lower"=>"/test-1506711855/spec-find-dir-test-1506711856",
      #  "path_display"=>"/test-1506711855/spec-find-dir-test-1506711856",
      #  "id"=>"id:UcOSbd2F8u4AAAAAAAABTw"
      # }
      include Dropbox::API::Fileops
      attr_accessor :name,
                    :path,
                    :path_lower,
                    :path_display,
                    :id

      def initialize response={}, client
        self.update response
        super
      end

      def update response
        self.name         = response['name']
        self.path         = response['path_display'] || response[:path]
        self.path_lower   = response['path_lower']
        self.path_display = response['path_display']
        self.id           = response['id']
      end

      def ls(path_to_list = '')
        data = client.raw.ls path: self.path + path_to_list
        Dropbox::API::Object.convert data['entries'] || [], client
      end

      def direct_url(options = {})
        response = client.raw.shares({ path: self.path, short_url: false }.merge(options))
        Dropbox::API::Object.new(response, client)
      end

      def is_deleted?
        false
      end

    end

  end
end
