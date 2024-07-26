module WeatherForecastsHelper
  def current_temperature
    @forecast.current_temperature
  end

  def address
    @forecast.address
  end

  def cached?
    @forecast.cached
  end
end
