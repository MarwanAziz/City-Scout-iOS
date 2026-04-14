//
//  SharedResources.swift
//  CityScoutLibraries
//
//  Created by Marwan Aziz on 12/04/2026.
//
 import CityScoutShared

public enum SharedResourcesError: LocalizedError {
  case missingAPIKeys

  public var errorDescription: String? {
    switch self {
    case .missingAPIKeys:
      return "Missing API keys. Configure RAPID_API_KEY and WEATHER_API_KEY."
    }
  }
}

@MainActor
public class SharedResources {
  public static let shared: SharedResources = SharedResources()
  public init() { }
  private var rapidApiKey: String?
  private var weatherApiKey: String?

  public func initialise(rapidApiKey: String, weatherApiKey: String) {
    self.rapidApiKey = rapidApiKey
    self.weatherApiKey = weatherApiKey
  }

  public func createSearchCityViewModel() throws -> SearchCityViewModel {
    guard let rapidApiKey, let weatherApiKey else {
      throw SharedResourcesError.missingAPIKeys
    }
    let remote = RemoteKeys.shared
    remote.rapidApiKey = rapidApiKey
    remote.weatherApiKey = weatherApiKey
    let remoteKey = CityScoutFactory.shared.createRemote(remoteKeys: remote)
    return CityScoutFactory.shared.creatSearchCityViewModel(remote: remoteKey)
  }

  public func createCityWeatherViewModel() throws -> CityWeatherViewModel {
    guard let rapidApiKey, let weatherApiKey else {
      throw SharedResourcesError.missingAPIKeys
    }
    let remote = RemoteKeys.shared
    remote.rapidApiKey = rapidApiKey
    remote.weatherApiKey = weatherApiKey
    let remoteKey = CityScoutFactory.shared.createRemote(remoteKeys: remote)
    return CityScoutFactory.shared.createWeatherViewModel(remote: remoteKey)
  }
}
