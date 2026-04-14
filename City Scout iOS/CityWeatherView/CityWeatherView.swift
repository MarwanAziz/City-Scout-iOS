//
//  CityWeatherView.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 13/04/2026.
//

import SwiftUI
import CityScoutShared

struct CityWeatherView: View {
  let city: SearchCityResult
  @StateObject private var viewModel = CityWeatherViewModelWrapper()
  @State private var isTemperatureInCelsius: Bool = true

  private var currentWeatherView: some View {
    VStack(spacing: 0) {
      if let weatherIcon = viewModel.conditionIcon.normalizedWeatherIconURL, !weatherIcon.isEmpty {
        RemoteWeatherIconView(urlString: weatherIcon, size: 75)
      } else {
        Image(systemName: "cloud")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
      }
      Text(viewModel.temperature ?? "")
        .font(.system(size: 51, weight: .heavy, design: .default))
        .fontWeight(.heavy)
        .bold()

      Text(viewModel.condition)
        .font(.headline)
        .fontWeight(.bold)

      Text(viewModel.feelsLike)
        .font(.subheadline)
        .padding()

      HStack(alignment: .top) {
        WeatherMetricCard(systemImage: "drop", title: "HUMIDITY", value: viewModel.humidity)
        WeatherMetricCard(systemImage: "wind", title: "WIND", value: viewModel.windSpeed)
        WeatherMetricCard(systemImage: "eye", title: "VISIBILITY", value: viewModel.visibility)
      }
      .padding(.horizontal)
    }
  }

  private var forecastWeatherView: some View {
    VStack {
      let numberOfDays: Int = viewModel.forecasts.count
      Text("\(numberOfDays)-DAY FORECAST")
        .font(.body)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)

      HStack(spacing: 8) {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(Array(viewModel.forecasts.enumerated()), id: \.offset) { _, forecast in
              ForecastDayCard(
                day: forecast.dayOfWeek,
                weather: forecast.weatherConditionText_,
                maxTemp: forecast.weatherMaxTemp,
                minTemp: forecast.weatherMinTemp,
                icon: forecast.weatherConditionIcon_.normalizedWeatherIconURL ?? "",
                humidity: forecast.weatherHumidity_
              )
            }
          }
          .padding(.leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var bodyView: some View {
    VStack(spacing: 0) {
      currentWeatherView
      Divider()
        .padding()
      forecastWeatherView
      Spacer()
      Picker("Unit", selection: $isTemperatureInCelsius) {
        Text("Celsius").tag(true)
        Text("Fahrenheit").tag(false)
      }
      .pickerStyle(.menu)
      .padding()
      .onChange(of: isTemperatureInCelsius) { _, _ in
        guard viewModel.isCelsius != isTemperatureInCelsius else { return }
        viewModel.toggleTemperatureUnit()
      }
    }
  }

  var body: some View {
    VStack {

      if viewModel.isLoading {
        VStack {
          ProgressView {
            Text("Loading...")
          }
        }
      } else if let error = viewModel.error {
        Text(error)
          .foregroundStyle(.red)
      } else {
        bodyView
      }
    }
    .navigationTitle(city.name)
    .navigationSubtitle(city.country)
    .task {
      await viewModel.loadWeather(for: city)
    }
  }
}

private struct WeatherMetricCard: View {
  let systemImage: String
  let title: String
  let value: String

  var body: some View {
    VStack {
      Image(systemName: systemImage)
        .resizable()
        .scaledToFit()
        .frame(width: 25, height: 25)
        .foregroundStyle(.secondary)
      Text(title)
        .font(.callout)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.body)
        .fontWeight(.bold)
        .foregroundStyle(.primary)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color(.systemBackground))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(.secondary.opacity(0.3), lineWidth: 1)
    )
  }
}

private struct ForecastDayCard: View {
  let day: String
  let weather: String
  let maxTemp: String
  let minTemp: String
  let icon: String
  let humidity: String

  var body: some View {
    VStack(alignment: .center, spacing: 8) {
      Text(day)
        .font(.caption)
        .fontWeight(.bold)
        .foregroundStyle(.primary)

      RemoteWeatherIconView(urlString: icon, size: 30)

      Text(weather)
        .font(.caption)
        .foregroundStyle(.secondary)

      HStack(alignment: .top, spacing: 4) {
        Text(maxTemp)
          .font(.caption)
          .fontWeight(.bold)
          .foregroundStyle(.primary)
        Text(minTemp)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text("💧\(humidity)")
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .padding(8)
    .background(Color(.systemBackground))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1))
    )
  }
}

private struct RemoteWeatherIconView: View {
  let urlString: String
  let size: CGFloat

  var body: some View {
    if let url = URL(string: urlString), !urlString.isEmpty {
      AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(width: size, height: size)
        case .success(let image):
          image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
        case .failure:
          Image(systemName: "cloud")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.secondary)
        @unknown default:
          EmptyView()
        }
      }
    } else {
      Image(systemName: "cloud")
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .foregroundStyle(.secondary)
    }
  }
}

private extension String {
  var normalizedWeatherIconURL: String? {
    if hasPrefix("//") {
      return "https:" + self
    }
    return self
  }
}

private extension Optional where Wrapped == String {
  var normalizedWeatherIconURL: String? {
    guard let value = self else { return nil }
    return value.normalizedWeatherIconURL
  }
}
