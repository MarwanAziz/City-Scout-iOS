//
//  InitialisedShareResource.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 13/04/2026.
//

import SharedResources
import Foundation

private enum AppConfigurationKeys {
  static let rapidAPIKey = "RAPID_API_KEY"
  static let weatherAPIKey = "WEATHER_API_KEY"
}

private struct AppConfiguration {
  let rapidAPIKey: String
  let weatherAPIKey: String

  static func load(from bundle: Bundle = .main) -> AppConfiguration? {
    let bundledEnv = loadBundledEnvironment(from: bundle)
    let rapidFromBundledEnv = bundledEnv[AppConfigurationKeys.rapidAPIKey]
    let weatherFromBundledEnv = bundledEnv[AppConfigurationKeys.weatherAPIKey]

    let rapidAPIKey =  rapidFromBundledEnv?.trimmingCharacters(in: .whitespacesAndNewlines)
    let weatherAPIKey = weatherFromBundledEnv?.trimmingCharacters(in: .whitespacesAndNewlines)

    guard
      let rapidAPIKey,
      let weatherAPIKey,
      !rapidAPIKey.isEmpty,
      !weatherAPIKey.isEmpty
    else {
      return nil
    }

    return AppConfiguration(rapidAPIKey: rapidAPIKey, weatherAPIKey: weatherAPIKey)
  }

  private static func loadBundledEnvironment(from bundle: Bundle) -> [String: String] {
    guard let url = bundle.url(forResource: "RuntimeEnv", withExtension: "sh"),
          let content = try? String(contentsOf: url, encoding: .utf8) else {
      return [:]
    }

    var values: [String: String] = [:]
    for line in content.components(separatedBy: .newlines) {
      let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }

      let normalized = trimmed.hasPrefix("export ")
        ? String(trimmed.dropFirst("export ".count))
        : trimmed
      let parts = normalized.split(separator: "=", maxSplits: 1).map(String.init)
      guard parts.count == 2 else { continue }

      let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
      let value = parts[1]
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
      values[key] = value
    }

    return values
  }
}

@MainActor
private enum SharedResourceProvider {
  static let shared: SharedResources = {
    let resources = SharedResources.shared
    if let configuration = AppConfiguration.load() {
      resources.initialise(
        rapidApiKey: configuration.rapidAPIKey,
        weatherApiKey: configuration.weatherAPIKey
      )
    }
    return resources
  }()
}

@MainActor
var shareResource: SharedResources {
  SharedResourceProvider.shared
}
