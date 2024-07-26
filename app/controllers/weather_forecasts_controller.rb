class WeatherForecastsController < ApplicationController
  def forecast
    @forecast = WeatherForecast.new(forecast_params)

    respond_to :html
  end

  private

  def forecast_params
    params.permit(:address)
  end
end
