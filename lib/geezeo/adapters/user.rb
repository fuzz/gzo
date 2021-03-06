module Geezeo
  module Adapters
    class User
      attr_reader :credentials

      include Requestable

      def initialize(credentials)
        @credentials = credentials
      end

      def uri
        "#{HOST}/users/#{credentials.user_id}"
      end

      def me
        response = request(:get, uri)

        Geezeo::User.new(response)
      end
    end
  end
end
