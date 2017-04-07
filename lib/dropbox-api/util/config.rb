module Dropbox
  module API

    module Config

      class << self
        attr_accessor :endpoints
        attr_accessor :prefix
        attr_accessor :app_key
        attr_accessor :app_secret
        attr_accessor :mode
      end

      self.endpoints = {
        :main      => "https://api.dropboxapi.com",
        :content   => "https://content.dropboxapi.com",
        :authorize => "https://www.dropbox.com"
      }
      self.prefix     = "/2"
      self.app_key    = nil
      self.app_secret = nil
      self.mode       = 'sandbox'

    end

  end
end
