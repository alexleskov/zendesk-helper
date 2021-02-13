# frozen_string_literal: true

class Request
  SOURCE = ""
  DEFAULT_TIMEOUT = 1

  attr_reader :client, :headers

  def initialize(params)
    raise "Headers must be a Hash" unless params[:headers].is_a?(Hash)

    @client = params[:client]
    @headers = params[:headers] || {}
    set_default_headers
  end

  def get(url)
    client.adapter.get(url, headers)
  end

  def post(url, payload)
    client.adapter.post(url, JSON.generate(payload), headers)
  end

  def put(url, payload)
    client.adapter.put(url, JSON.generate(payload), headers)
  end

  def delete(url)
    client.adapter.delete(url, headers)
  end

  protected

  def call_api
    response = yield
    return unless response.body

    JSON.parse(response.body)
  rescue RuntimeError => e
    return e.response unless e.respond_to?(:http_code)

    case e.http_code
    when 301, 302, 307
      e.response.follow_redirection
    when 429
      timeout = e.http_headers[:retry_after] || DEFAULT_TIMEOUT
      sleep(timeout.to_i)
      retry
    when 422, 500, 502, 503
      p on_api_error(e)
      return
    else
      raise on_api_error(e)
    end
  rescue Errno::ECONNRESET => e
    p "Errno::ECONNRESET: #{e.inspect}"
    retry
  end

  def set_default_headers
    @headers["Content-Type"] = "application/json; utf-8"
    @headers["Accept"] = "application/json"
  end

  private

  def on_api_error(error)
    "Call API Error: #{error.http_code} - #{error.inspect}"
  end
end
