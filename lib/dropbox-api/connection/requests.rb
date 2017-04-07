require 'json'

module Dropbox
  module API

    class Connection

      module Requests

        def request(options = {})
          response = yield
          raise Dropbox::API::Error::ConnectionFailed if !response
          status = (response.respond_to?(:code) ? response.code : response.status).to_i
          case status
            when 400
              raise Dropbox::API::Error::BadInput.new("400 - Bad input parameter - #{response.body}")
            when 401
              raise Dropbox::API::Error::Unauthorized.new("401 - Bad or expired token")
            when 404
              raise Dropbox::API::Error::NotFound.new("404 - Not found")
            when 409
              parsed = MultiJson.decode(response.body)
              raise Dropbox::API::Error.new("409 - #{parsed['error_summary']}")
            when 429
              raise Dropbox::API::Error::RateLimit.new('429 - Rate Limiting in affect')
            when 300..399
              raise Dropbox::API::Error::Redirect.new("#{status} - Redirect Error")
            when 503
              handle_503 response
            when 507
              raise Dropbox::API::Error::StorageQuota.new("507 - Dropbox storage quota exceeded.")
            when 500..502, 504..506, 508..599
              parsed = MultiJson.decode(response.body)
              raise Dropbox::API::Error.new("#{status} - Server error. Check http://status.dropbox.com/")
            else
              options[:raw] ? response.body : MultiJson.decode(response.body)
          end
        end

        def handle_503(response)
          if response.is_a? Net::HTTPServiceUnavailable
            raise Dropbox::API::Error.new("503 - #{response.message}")
          else
            parsed = MultiJson.decode(response.body)
            header_parse = MultiJson.decode(response.headers)
            error_message = "#{parsed["error"]}. Retry after: #{header_parse['Retry-After']}"
            raise Dropbox::API::Error.new("503 - #{error_message}")
          end
        end

        def get_raw(endpoint, path, data = {}, headers = {})
          headers["Content-Type"] ||= "application/json"
          request_url = "#{Dropbox::API::Config.prefix}#{path}"
          request(:raw => true) do
            token(endpoint).get request_url, :body => ::JSON.dump(data), :headers => headers, :raise_errors => false
          end
        end

        def get(endpoint, path, data = {}, headers = {})
          do_request :get, endpoint, path, data, headers
        end

        def post(endpoint, path, data = {}, headers = {})
          do_request :post, endpoint, path, data, headers
        end

        def put(endpoint, path, data = {}, headers = {})
          do_request :put, endpoint, path, data, headers
        end

        private

        def do_request(method, endpoint, path, data = "", headers = {})
          headers["Content-Type"] ||= "application/json"
          request_url = "#{Dropbox::API::Config.prefix}#{path}"
          request do
            token(endpoint).send method, request_url, :body => ::JSON.dump(data), :headers => headers, :raise_errors => false
          end
        end

      end

    end

  end
end
