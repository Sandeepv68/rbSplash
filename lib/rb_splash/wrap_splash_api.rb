# frozen_string_literal: true

require "digest"
require "concurrent/promises"

module RbSplash
  class WrapSplashApi
    AVAILABLE_ORDERS = %w[latest oldest popular].freeze
    AVAILABLE_ORIENTATIONS = %w[landscape portrait squarish].freeze

    def initialize
      @api_location = UrlConfig::API_LOCATION
      @bearer_token_url = UrlConfig::BEARER_TOKEN_URL
      @access_key = ""
      @secret_key = ""
      @redirect_uri = ""
      @code = ""
      @grant_type = "authorization_code"
      @bearer_token = ""
      @timeout = 10_000
      @retries = 2
      @retry_delay_ms = 100
      @headers = {
        "Content-type" => "application/json",
        "X-Requested-With" => "WrapSplash"
      }
    end

    def init(options = {})
      raise WrapSplashError, "Initialisation parameters required!" unless options.is_a?(Hash) && !options.empty?

      @timeout = options[:timeout].is_a?(Numeric) && options[:timeout].positive? ? options[:timeout] : 10_000
      @retries = options[:retries].is_a?(Numeric) && options[:retries] >= 0 ? options[:retries] : 2
      @retry_delay_ms = options[:retry_delay_ms].is_a?(Numeric) && options[:retry_delay_ms] >= 0 ? options[:retry_delay_ms] : 100
      @bearer_token = options[:bearer_token] || ""

      @headers = {
        "Content-type" => "application/json",
        "X-Requested-With" => "WrapSplash"
      }

      if options[:bearer_token]
        @headers["Authorization"] = "Bearer #{options[:bearer_token]}"
        @headers["X-WrapSplash-Header"] = compute_hash(options[:bearer_token])
        return
      end

      @access_key = options[:access_key] || raise(WrapSplashError, "Access Key missing!")
      @secret_key = options[:secret_key] || raise(WrapSplashError, "Secret Key missing!")
      @redirect_uri = options[:redirect_uri] || raise(WrapSplashError, "Redirect URI missing!")
      @code = options[:code] || raise(WrapSplashError, "Authorization Code missing!")

      @headers["Authorization"] = "Client-ID #{options[:access_key]}"
      @headers["X-WrapSplash-Header"] = compute_hash(options[:access_key])
    end

    def generate_bearer_token
      validate_required(@access_key, "access_key")
      validate_required(@secret_key, "secret_key")
      validate_required(@redirect_uri, "redirect_uri")
      validate_required(@code, "code")

      result = fetch_url(@bearer_token_url, "POST", {}, {
        client_id: @access_key,
        client_secret: @secret_key,
        redirect_uri: @redirect_uri,
        code: @code,
        grant_type: @grant_type
      })

      clear_credentials!

      result
    end

    def get_current_user_profile
      fetch_url(@api_location + UrlConfig::CURRENT_USER_PROFILE, "GET")
    end

    def update_current_user_profile(username: nil, first_name: nil, last_name: nil, email: nil, url: nil, location: nil, bio: nil, instagram_username: nil)
      fetch_url(@api_location + UrlConfig::UPDATE_CURRENT_USER_PROFILE, "PUT", {
        username: username, first_name: first_name, last_name: last_name,
        email: email, url: url, location: location, bio: bio,
        instagram_username: instagram_username
      })
    end

    def get_public_profile(username, width: nil, height: nil)
      validate_required(username, "username")
      fetch_url(@api_location + UrlConfig::USERS_PUBLIC_PROFILE + username, "GET", { w: width, h: height })
    end

    def get_user_portfolio(username)
      validate_required(username, "username")
      fetch_url(@api_location + UrlConfig::USERS_PORTFOLIO.gsub(":username", username), "GET")
    end

    def get_user_photos(username, page: 1, per_page: 10, stats: false, resolution: "days", quantity: 30, order_by: "latest")
      validate_required(username, "username")
      validate_supported_value(order_by, AVAILABLE_ORDERS, "order_by")
      fetch_url(@api_location + UrlConfig::USERS_PHOTOS.gsub(":username", username), "GET", {
        page: page, per_page: per_page, order_by: order_by,
        stats: stats, resolution: resolution, quantity: quantity
      })
    end

    def get_user_liked_photos(username, page: 1, per_page: 10, order_by: "latest")
      validate_required(username, "username")
      validate_supported_value(order_by, AVAILABLE_ORDERS, "order_by")
      fetch_url(@api_location + UrlConfig::USERS_LIKED_PHOTOS.gsub(":username", username), "GET", {
        page: page, per_page: per_page, order_by: order_by
      })
    end

    def get_user_collections(username, page: 1, per_page: 10)
      validate_required(username, "username")
      fetch_url(@api_location + UrlConfig::USERS_COLLECTIONS.gsub(":username", username), "GET", {
        page: page, per_page: per_page
      })
    end

    def get_user_statistics(username, resolution: "days", quantity: 30)
      validate_required(username, "username")
      fetch_url(@api_location + UrlConfig::USERS_STATISTICS.gsub(":username", username), "GET", {
        resolution: resolution, quantity: quantity
      })
    end

    def list_photos(page: 1, per_page: 10, order_by: "latest")
      validate_supported_value(order_by, AVAILABLE_ORDERS, "order_by")
      fetch_url(@api_location + UrlConfig::LIST_PHOTOS, "GET", {
        page: page, per_page: per_page, order_by: order_by
      })
    end

    def list_curated_photos(page: 1, per_page: 10, order_by: "latest")
      validate_supported_value(order_by, AVAILABLE_ORDERS, "order_by")
      fetch_url(@api_location + UrlConfig::LIST_CURATED_PHOTOS, "GET", {
        page: page, per_page: per_page, order_by: order_by
      })
    end

    def get_a_photo(id, width: nil, height: nil, rect: nil)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_A_PHOTO.gsub(":id", id), "GET", {
        w: width, h: height, rect: rect
      })
    end

    alias get_photo get_a_photo

    def get_a_random_photo(collections: nil, featured: false, username: nil, query: nil, width: nil, height: nil, orientation: "landscape", count: 1)
      validate_supported_value(orientation, AVAILABLE_ORIENTATIONS, "orientation")
      fetch_url(@api_location + UrlConfig::GET_A_RANDOM_PHOTO, "GET", {
        collections: collections&.to_s, featured: featured, username: username,
        query: query, width: width, height: height, orientation: orientation, count: count
      })
    end

    alias get_random_photo get_a_random_photo

    def get_photo_statistics(id, resolution: "days", quantity: 30)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_A_PHOTO_STATISTICS.gsub(":id", id), "GET", {
        resolution: resolution, quantity: quantity
      })
    end

    def get_photo_link(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_A_PHOTO_DOWNLOAD_LINK.gsub(":id", id), "GET")
    end

    def update_photo(id, location: {}, exif: {})
      validate_required(id, "id")
      params = {}
      params["location[latitude]"] = location[:latitude] if location[:latitude]
      params["location[longitude]"] = location[:longitude] if location[:longitude]
      params["location[name]"] = location[:name] if location[:name]
      params["location[city]"] = location[:city] if location[:city]
      params["location[country]"] = location[:country] if location[:country]
      params["location[confidential]"] = location[:confidential] if location[:confidential]
      params["exif[make]"] = exif[:make] if exif[:make]
      params["exif[model]"] = exif[:model] if exif[:model]
      params["exif[exposure_time]"] = exif[:exposure_time] if exif[:exposure_time]
      params["exif[aperture_value]"] = exif[:aperture_value] if exif[:aperture_value]
      params["exif[focal_length]"] = exif[:focal_length] if exif[:focal_length]
      params["exif[iso_speed_ratings]"] = exif[:iso_speed_ratings] if exif[:iso_speed_ratings]
      fetch_url(@api_location + UrlConfig::UPDATE_A_PHOTO.gsub(":id", id), "PUT", params)
    end

    def like_photo(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::LIKE_A_PHOTO.gsub(":id", id), "POST")
    end

    def unlike_photo(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::UNLIKE_A_PHOTO.gsub(":id", id), "DELETE")
    end

    def search(query, page: 1, per_page: 10, collections: nil, orientation: nil)
      validate_required(query, "query")
      validate_supported_value(orientation, AVAILABLE_ORIENTATIONS, "orientation")
      fetch_url(@api_location + UrlConfig::SEARCH_PHOTOS, "GET", {
        query: query, page: page, per_page: per_page,
        collections: collections&.to_s, orientation: orientation
      })
    end

    def search_collections(query, page: 1, per_page: 10)
      validate_required(query, "query")
      fetch_url(@api_location + UrlConfig::SEARCH_COLLECTIONS, "GET", {
        query: query, page: page, per_page: per_page
      })
    end

    def search_users(query, page: 1, per_page: 10)
      validate_required(query, "query")
      fetch_url(@api_location + UrlConfig::SEARCH_USERS, "GET", {
        query: query, page: page, per_page: per_page
      })
    end

    def get_stats_totals
      fetch_url(@api_location + UrlConfig::STATS_TOTALS, "GET")
    end

    def get_stats_month
      fetch_url(@api_location + UrlConfig::STATS_MONTH, "GET")
    end

    def list_collections(page: 1, per_page: 10)
      fetch_url(@api_location + UrlConfig::LIST_COLLECTIONS, "GET", {
        page: page, per_page: per_page
      })
    end

    def list_featured_collections(page: 1, per_page: 10)
      fetch_url(@api_location + UrlConfig::LIST_FEATURED_COLLECTIONS, "GET", {
        page: page, per_page: per_page
      })
    end

    def list_curated_collections(page: 1, per_page: 10)
      fetch_url(@api_location + UrlConfig::LIST_CURATED_COLLECTIONS, "GET", {
        page: page, per_page: per_page
      })
    end

    def get_collection(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_COLLECTION.gsub(":id", id), "GET")
    end

    def get_curated_collection(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_CURATED_COLLECTION.gsub(":id", id), "GET")
    end

    def get_collection_photos(id, page: 1, per_page: 10)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_COLLECTION_PHOTOS.gsub(":id", id), "GET", {
        page: page, per_page: per_page
      })
    end

    def get_curated_collection_photos(id, page: 1, per_page: 10)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::GET_CURATED_COLLECTION_PHOTOS.gsub(":id", id), "GET", {
        page: page, per_page: per_page
      })
    end

    def list_related_collections(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::LIST_RELATED_COLLECTION.gsub(":id", id), "GET")
    end

    def create_new_collection(title, description: nil, private_collection: false)
      validate_required(title, "title")
      fetch_url(@api_location + UrlConfig::CREATE_NEW_COLLECTION, "POST", {
        title: title, description: description, private: private_collection
      })
    end

    alias create_collection create_new_collection

    def update_existing_collection(id, title, description: nil, private_collection: false)
      validate_required(id, "id")
      validate_required(title, "title")
      fetch_url(@api_location + UrlConfig::UPDATE_EXISTING_COLLECTION.gsub(":id", id), "PUT", {
        title: title, description: description, private: private_collection
      })
    end

    alias update_collection update_existing_collection

    def delete_collection(id)
      validate_required(id, "id")
      fetch_url(@api_location + UrlConfig::DELETE_COLLECTION.gsub(":id", id), "DELETE")
    end

    def add_photo_to_collection(collection_id, photo_id)
      validate_required(collection_id, "collection_id")
      validate_required(photo_id, "photo_id")
      fetch_url(@api_location + UrlConfig::ADD_PHOTO_TO_COLLECTION.gsub(":collection_id", collection_id), "POST", {
        photo_id: photo_id
      })
    end

    def remove_photo_from_collection(collection_id, photo_id)
      validate_required(collection_id, "collection_id")
      validate_required(photo_id, "photo_id")
      fetch_url(@api_location + UrlConfig::REMOVE_PHOTO_FROM_COLLECTION.gsub(":collection_id", collection_id), "DELETE", {
        photo_id: photo_id
      })
    end

    private

    def compute_hash(value)
      Digest::SHA256.hexdigest(value)
    end

    def validate_required(value, field_name)
      return if value && !value.to_s.empty?

      message = case field_name
                when "id" then "Parameter : id is required!"
                when "query" then "Parameter : query is missing!"
                else "Parameter : #{field_name} is required and cannot be empty!"
                end
      raise WrapSplashError, message
    end

    def validate_supported_value(value, allowed_values, field_name)
      return if value.nil?
      return if allowed_values.include?(value)

      raise WrapSplashError, "Parameter : #{field_name} has an unsupported value!"
    end

    def build_query_parameters(params)
      params.select { |_, v| !v.nil? && !v.to_s.empty? }
    end

    def fetch_url(url, method, query_parameters = {}, body = nil)
      Concurrent::Promises.future do
        http = HttpClient.new(
          headers: @headers,
          timeout: @timeout,
          retries: @retries,
          retry_delay_ms: @retry_delay_ms
        )

        response = http.make_request(url, method, query_parameters: build_query_parameters(query_parameters), body: body)

        if response.status == 204
          { status: 204, status_text: response.status_text, message: "Content Deleted" }
        elsif response.status == 403
          { status: 403, status_text: response.status_text, message: "Rate Limit Exceeded" }
        else
          response.data
        end
      end.rescue do |e|
        raise create_wrap_splash_error(e)
      end
    end

    def create_wrap_splash_error(error)
      return error if error.is_a?(WrapSplashError)

      status_code = error.respond_to?(:response) && error.response&.dig(:status)
      status_text = error.respond_to?(:response) && error.response&.dig(:status_text)

      WrapSplashError.new(
        get_error_message(error),
        status_code: status_code,
        status_text: status_text,
        cause: error
      )
    end

    def get_error_message(error)
      return error.message if error.is_a?(StandardError)
      return error if error.is_a?(String)

      "Request failed"
    end

    def clear_credentials!
      @access_key = nil
      @secret_key = nil
      @redirect_uri = nil
      @code = nil
    end
  end
end
