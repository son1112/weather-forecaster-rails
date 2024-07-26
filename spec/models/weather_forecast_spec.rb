# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherForecast do
  let(:address) { "123 Your way lowercase or Uppercase city state zip country if you want, this library is pretty handy with string" }
  let(:weather_forecast) { build(:weather_forecast, address: address ) }
  let(:lat) { 43.733478 }
  let(:lng) { -79.375314 }
  # let(:geocoder_api_key) { "mock_valid_api_key" }

  # TODO: consider injecting client dependencies to improve testing, reduce mocks
  let(:geocoder) do
    instance_double(
      OpenCage::Geocoder,
      # api_key: geocoder_api_key,
      geocode: geocode_response
    )
  end
  let(:geocode_response) { [location_data] }
  let(:location_data) do
    instance_double(
      OpenCage::Geocoder::Location,
      lat: lat,
      lng: lng
    )
  end

  let(:forecaster) do
    instance_double(
      OpenMeteo::Forecast,
      get: forecast_response,
    )
  end
  let(:forecast_response) do
    instance_double(
      OpenMeteo::Entities::Forecast,
      current: current_forecast
    )
  end
  let(:current_forecast) do
    instance_double(
      OpenMeteo::Entities::Forecast::Current,
      item: current_forecast_item,
    )
  end
  let(:current_forecast_item) do
    double(
      OpenMeteo::Entities::Forecast::Item,
      temperature_2m: celcius
    )
  end
  let(:celcius) { 32.2 }

  before do
    allow(OpenCage::Geocoder).to receive(:new).and_return(geocoder)
    allow(OpenMeteo::Forecast).to receive(:new).and_return(forecaster)
  end

  it "initiates" do
    expect(weather_forecast.address).to be_a(String)
  end

  describe "#current_temperature" do
    subject { weather_forecast.current_temperature }

    context "with a valid api key" do

      context "with a valid address" do

        it "returns the current temperature" do
          expect(subject).to be_a(Float)
        end

        context "with temperature units" do
          subject { weather_forecast.current_temperature(unit) }

          context "in celcius" do
            let(:unit) { :celcius }

            it "returns the current temperature" do
              expect(subject).to be_a(Float)
            end
          end

          context "in farenheit" do
            let(:unit) { :farenheit }

            it "returns the current temperature" do
              expect(subject).to be_a(Float)
            end
          end

          context "in unsupported unit" do
            let(:unit) { :flargalots }

            it "returns the current temperature" do
              expect { subject }.to raise_error
            end
          end
        end
      end
    end

    context "with an invalid api key" do
      # TODO: mock and test error handling
    end
  end
end
