require "test_helper"

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get weather_forecasts_create_url
    assert_response :success
  end
end
