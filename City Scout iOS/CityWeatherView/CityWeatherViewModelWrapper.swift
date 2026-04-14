//
//  CityWeatherViewModelWrapper.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 13/04/2026.
//

import Foundation
import Combine
import CityScoutShared
import SharedResources
import KMPNativeCoroutinesCombine
import KMPNativeCoroutinesAsync


@MainActor
final class CityWeatherViewModelWrapper: ObservableObject {
  typealias ViewModelFactory = () throws -> CityWeatherViewModel

  private var viewModel: CityWeatherViewModel?
  private var cancellables = Set<AnyCancellable>()
  @Published var isLoading: Bool = false
  @Published var title: String = ""
  @Published var country: String = ""
  @Published var error: String?
  @Published var temperature: String?
  @Published var condition: String = ""
  @Published var conditionIcon: String = ""
  @Published var feelsLike: String = ""
  @Published var windSpeed: String = ""
  @Published var visibility: String = ""
  @Published var forecasts: [WeatherForecastViewModel] = []
  @Published var isCelsius: Bool = true

  @Published var humidity: String = ""

  convenience init() {
    self.init(viewModelFactory: { try shareResource.createCityWeatherViewModel() })
  }
  init(viewModelFactory: @escaping ViewModelFactory) {
    configureViewModel(with: viewModelFactory)
    observeLoading()
    observeTitle()
    observeCountry()
    observeTemp()
    observeForecast()
    observeVisibility()
    observeFeelsLikeTemp()
    observeTemperatureUnit()
    observeWindSpeed()
    observeConditionIcon()
    observeWeatherHumidity()
    observeConditions()
  }

  private func configureViewModel(with factory: ViewModelFactory) {
    do {
      viewModel = try factory()
    } catch {
      self.error = "Missing or invalid app configuration."
    }
  }

  private func bind<Value>(
    publisher: AnyPublisher<Value, Error>,
    dropFirst: Bool = true,
    receiveValue: @escaping (Value) -> Void
  ) {
    let stream = dropFirst ? publisher.dropFirst().eraseToAnyPublisher() : publisher.eraseToAnyPublisher()
    stream
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { _ in },
        receiveValue: receiveValue
      )
      .store(in: &cancellables)
  }

  private func observeLoading() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.loading)) { [weak self] value in
      self?.isLoading = value.boolValue
    }
  }

  private func observeTitle() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.title)) { [weak self] value in
      self?.title = value
    }
  }

  private func observeTemp() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherTemp)) { [weak self] value in
      self?.temperature = value
    }
  }

  private func observeCountry() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.country)) { [weak self] value in
      self?.country = value
    }
  }

  private func observeError() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherError)) { [weak self] value in
      self?.error = value.isEmpty ? nil : value
    }
  }

  private func observeConditionIcon() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherConditionIcon)) { [weak self] value in
      self?.conditionIcon = value ?? ""
    }
  }

  private func observeConditions() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherConditionText)) { [weak self] value in
      self?.condition = value
    }
  }

  private func observeWeatherHumidity() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherHumidity)) { [weak self] value in
      self?.humidity = value
    }
  }

  private func observeVisibility() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherVisibility)) { [weak self] value in
      self?.visibility = value
    }
  }

  private func observeFeelsLikeTemp() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherFeelsLike)) { [weak self] value in
      self?.feelsLike = value
    }
  }

  private func observeTemperatureUnit() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.isCelsius)) { [weak self] value in
      self?.isCelsius = value.boolValue
    }
  }

  private func observeWindSpeed() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.weatherWindSpeed)) { [weak self] value in
      self?.windSpeed = value
    }
  }

  private func observeForecast() {
    guard let viewModel else { return }
    bind(publisher: createPublisher(for: viewModel.forecasts)) { [weak self] value in
      self?.forecasts = value
    }
  }

  func loadWeather(for city: SearchCityResult) async {
    func showError(_ message: String = "Failed to load weather") {
      self.error = message
    }

    guard let viewModel else {
      showError()
      return
    }

    do {
      try await asyncFunction(for: viewModel.checkWeather(city: city))
    } catch {
      showError(error.localizedDescription)
    }
  }

  func toggleTemperatureUnit() {
    viewModel?.toggleTemperatureFormat()
  }
}
