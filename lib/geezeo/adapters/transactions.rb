module Geezeo
  module Adapters
    class Transactions
      attr_reader :credentials

      include Requestable

      def initialize(credentials)
        @credentials = credentials
      end

      def uri(account, page=1)
        "#{HOST}/users/#{credentials.user_id}/accounts/#{account.id}/transactions?page=#{page}"
      end 

      def all(recent=false)
        accounts = Geezeo::Adapters::Accounts.new(credentials).all
        transactions = accounts.map do |account|
          recent ? find(account) : find_all(account)
        end

        sort_by_posted_at(transactions.flatten)
      end

      def find_all(account, transaction_id="")
        pages = total_pages(account)
        results = []

        pages.times do |page|
          find(account, page+1).each do |transaction|
            if transaction["id"] == transaction_id
              return results.compact
            else
              results << transaction
            end
          end
        end

        results.compact
      end

      def find(account_id, page=1)
        account = account_id.is_a?(Integer) ? Geezeo::Adapters::Accounts.new(credentials).find(account_id) : account_id

        response = request(:get, uri(account, page))

        if response["transactions"]
          results = response["transactions"].map do |transaction|
            Geezeo::Transaction.new(transaction["transaction"])
          end
        else
          results = []
        end

        results.compact
      end

      def posted_at(transaction)
        Time.parse(transaction.posted_at) rescue Time.new(0)
      end

      def sort_by_posted_at(transactions)
        transactions.sort_by{|transaction| posted_at(transaction)}.reverse
      end

      def total_pages(account)
        response = request(:get, uri(account))
        response["pages"]["total_pages"].to_i
      end
    end
  end
end
