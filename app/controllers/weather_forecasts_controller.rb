class WeatherForecastsController < ApplicationController
  def create
    # address params
    weather_forecast = WeatherForecast.new(forecast_params)
    # geocoder

    weather_forecast

    # weather api
    # render
  end

  private

  def forecast_params
    params.permit(:street, :city, :state, :country, :zipcode)
  end
end
