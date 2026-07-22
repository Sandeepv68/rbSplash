# frozen_string_literal: true

require 'faraday'
require 'json'

require_relative 'response'

module RbSplash
  class HttpClient
    RETRYABLE_ERRORS = [
      Faraday::TimeoutError,
      Faraday::ConnectionFailed,
      Net::OpenTimeout,
      Net::ReadTimeout,
      Net::ProtocolError,
      IOError,
      Errno::ECONNRESET,
      Errno::ECONNREFUSED,
      Errno::ETIMEDOUT
    ].freeze

    def initialize(headers: {}, timeout: 10_000, retries: 2, retry_delay_ms: 100)
      @headers = headers
      @timeout = timeout
      @retries = retries
      @retry_delay_ms = retry_delay_ms
    end

    def make_request(url, method, query_parameters: {}, body: nil)
      raise ArgumentError, 'URL required' if url.nil? || url.empty?

      last_error = nil

      (0..@retries).each do |attempt|
        return execute_request(url, method, query_parameters, body)
      rescue *RETRYABLE_ERRORS => e
        last_error = e
        sleep(@retry_delay_ms / 1000.0) if @retry_delay_ms.positive? && attempt < @retries
      end

      raise last_error
    end

    private

    def execute_request(url, method, query_parameters, body)
      conn = Faraday.new do |f|
        f.adapter Faraday.default_adapter
      end

      response = conn.send(method.downcase.to_sym, url) do |req|
        req.headers.merge!(@headers)
        req.params.merge!(query_parameters.transform_keys(&:to_s)) if query_parameters.any?
        req.body = body.to_json if body
        req.options.timeout = @timeout / 1000.0
      end

      data = response.body.to_s.empty? ? {} : parse_json(response.body)

      result = Response.new(
        status: response.status,
        status_text: response.reason_phrase,
        data: data
      )

      unless response.status.between?(200, 299)
        error_message = "HTTP #{response.status}: #{response.reason_phrase}"
        error_message += " - #{response.body}" if response.body && !response.body.empty?
        raise StandardError, error_message
      end

      result
    end

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError
      { raw: body }
    end
  end
end
