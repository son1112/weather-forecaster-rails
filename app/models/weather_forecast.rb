# frozen_string_literal: true

require "open_meteo"

class WeatherForecast
  include ActiveModel::Model

  attr_accessor :address, :cached

  OPENCAGE_API_KEY = Rails.application.credentials.dig(:opencage_api_key)

  def current_temperature(unit = :farenheit)
    forecast

    celcius = @weather_data.dig("current", "item", "raw_json", "temperature_2m")

    case unit
    when :celcius
      celcius
    when :farenheit
      celcius * (9/5.0) + 32
    else
      # TODO: custom error handling classes
      Raise "NotImplemented"
    end
  end

  private

  def forecast
    @weather_data = if cached_weather_data.present?
                      self.cached = true
                      cached_weather_data
                    else
                      self.cached = false
                      fetch_weather_data
                    end
    # @weather_data = cached_weather_data || fetch_weather_data
  end

  def cached_weather_data
    value = Rails.cache.read(forecast_cache_key)

    JSON.parse(value)
  rescue TypeError => _e
    # TODO: make this error handling more specific
    nil
  end

  def fetch_weather_data
    weather_data = OpenMeteo::Forecast.new.get(
      location: location,
      variables: variables
    )

    Rails.cache.write(forecast_cache_key, weather_data.to_json)

    cached_weather_data
  end

  def forecast_cache_key
    "#{address_cache_key}/current_weather"
  end

  def address_cache_key
    address.gsub(" ", "_").gsub("\"", "")
  end

  def variables
    {
      current: %i[weather_code temperature_2m],
      hourly: %i[weather_code temperature_2m],
      daily: %i[]
    }
  end

  def location
    return unless latitude && longitude

    # TODO: error handling
    # TODO: consider injection of 3rd party dependency classes
    OpenMeteo::Entities::Location.new(latitude: latitude.to_d, longitude: longitude.to_d)
  end

  def latitude
    return unless geocode_data

    geocode_data.first.lat
  end

  def longitude
    return unless geocode_data

    geocode_data.first.lng
  end

  def geocoder
    # TODO: error handling
    # https://github.com/opencagedata/ruby-opencage-geocoder?tab=readme-ov-file#error-handling
    # TODO: consider injection of 3rd party dependency classes
    @geocoder ||= OpenCage::Geocoder.new(api_key: OPENCAGE_API_KEY)
  rescue OpenCage::Geocoder::AuthenticationError => e
    raise "Geocoder: Invalid API Key"
  rescue OpenCage::Geocoder::QuotaExceeded => e
    raise "Geocoder: Quota exceeded"
  rescue StandardError => e
    raise e
  end

  def geocode_data
    geocoder.geocode(address) if address
  end
end
