# frozen_string_literal: true

# TODO: consider moving to an initializer or separate client
# https://github.com/open-meteo-ruby/open-meteo-ruby?tab=readme-ov-file#global-configuration
require "open_meteo"

class WeatherForecast
  include ActiveModel::Model

  attr_accessor :address # :geocoder, :forecaster

  OPENCAGE_API_KEY = Rails.application.credentials.dig(:opencage_api_key)

  def current_temperature(unit = :farenheit)
    forecast

    celcius = @weather_data.current.item.temperature_2m

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
    # TODO: error handling
    # TODO: consider injection of 3rd party dependency classes

    # TODO: cache data for 30 minutes
    @weather_data = OpenMeteo::Forecast.new.get(
      location: location,
      variables: variables
    )
  end

  def variables
    {
      current: %i[weather_code temperature_2m],
      hourly: %i[weather_code temperature_2m],
      daily: %i[]
    }
  end

  def location
    # TODO: error handling
    # TODO: consider injection of 3rd party dependency classes
    OpenMeteo::Entities::Location.new(latitude: latitude.to_d, longitude: longitude.to_d)
  end

  def latitude
    geocode_data.first.lat
  end

  def longitude
    geocode_data.first.lng
  end

  def geocoder
    # TODO: error handling
    # https://github.com/opencagedata/ruby-opencage-geocoder?tab=readme-ov-file#error-handling
    # TODO: consider injection of 3rd party dependency classes
    @geocoder ||= OpenCage::Geocoder.new(api_key: OPENCAGE_API_KEY)
  end

  def geocode_data
    geocoder.geocode(address)
  end
end
