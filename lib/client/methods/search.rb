# frozen_string_literal: true

module Zendesk
  class Request
    class Search < Zendesk::Request
      SOURCE = "search"
      JSON = ".json"

      attr_reader :query, :options

      def initialize(params)
        @query = params[:query]
        raise "Query must be a Hash" unless query.is_a?(Hash)

        @options = params[:options]
        super(client: params[:client], headers: params[:headers])
      end

      def go
        result =
          call_api { get(request_url) }
        return unless result

        result
      end

      def request_url
        "#{super}#{SOURCE}#{JSON}?#{build_url_query}#{build_url_params}"
      end

      private

      def build_url_params
        return "" unless options

        "&#{build_data_by(options, '&', '=')}"
      end

      def build_url_query
        return "" unless query

        "query=#{build_data_by(query, '+', '%3A')}"
      end

      def build_data_by(hashed_options, options_delimeter, values_delimeter)
        return unless hashed_options

        result = []
        hashed_options.each { |option, value| result << [option, value].join(values_delimeter) }
        result.join(options_delimeter)
      end
    end
  end
end
