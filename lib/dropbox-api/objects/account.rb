require 'ostruct'
module Dropbox
  module API
    # {
    #   "account_id"=>"dbid:...................................",
    #   "name"=>{"given_name"=>"Andrew", "surname"=>"Brown", "familiar_name"=>"Andrew", "display_name"=>"Andrew Brown", "abbreviated_name"=>"AB"},
    #   "email"=>".........@gmail.com",
    #   "email_verified"=>true,
    #   "disabled"=>false,
    #   "country"=>"CA",
    #   "locale"=>"en",
    #   "referral_link"=>"https://db.tt/..........",
    #   "is_paired"=>false,
    #   "account_type"=>{".tag"=>"basic"}
    # }
    class Account < Dropbox::API::Object
      attr_accessor :account_id
      attr_accessor :name
      attr_accessor :email
      attr_accessor :email_verified
      attr_accessor :disabled
      attr_accessor :country
      attr_accessor :locale
      attr_accessor :referral_link
      attr_accessor :is_paired
      attr_accessor :account_type

      def initialize response={}, client
        self.account_id     = response['account_id']
        self.name           = OpenStruct.new response['name']
        self.email          = response['email']
        self.email_verified = response['email_verified']
        self.disabled       = response['disabled']
        self.country        = response['country']
        self.locale         = response['locale']
        self.referral_link  = response['referral_link']
        self.is_paired      = response['is_paired']
        self.account_type   = response['account_type']
        super
      end


    end
  end
end
