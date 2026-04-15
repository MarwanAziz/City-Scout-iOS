//
//  CitySearchViewModelWrapper.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 12/04/2026.
//

import Foundation
import SharedResources
import CityScoutShared
import KMPNativeCoroutinesAsync
import Combine

@MainActor
struct SearchCityViewState: Equatable {
  var query: String = ""
  var searchResults: [SearchCityResult] = []
  var isLoading: Bool = false
  var errorMessage: String? = nil
}

@MainActor
final class SearchCityStore: ObservableObject {
  typealias ViewModelFactory = () throws -> SearchCityViewModel

  @Published private(set) var state = SearchCityViewState()

  private var viewModel: SearchCityViewModel?
  private var observationTasks: [Task<Void, Never>] = []
  private var searchTask: Task<Void, Never>?

  convenience init() {
    self.init(viewModelFactory: { try shareResource.createSearchCityViewModel() })
  }

  init(viewModelFactory: @escaping ViewModelFactory) {
    configureViewModel(with: viewModelFactory)
    observeFlows()
  }

  private func configureViewModel(with factory: ViewModelFactory) {
    do {
      viewModel = try factory()
    } catch {
      state.errorMessage = String(localized: "errors.missingConfiguration")
    }
  }

  func setQuery(_ query: String) {
    guard state.isLoading == false else { return }
    state.query = query
    searchTask?.cancel()

    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQuery.isEmpty else {
      state.searchResults = []
      state.errorMessage = nil
      return
    }

    searchTask = Task { [weak self] in
      await self?.performSearch(with: trimmedQuery)
    }
  }

  func retrySearch() {
    setQuery(state.query)
  }

  private func performSearch(with query: String) async {
    guard let viewModel else {
      state.errorMessage = String(localized: "errors.searchUnavailable")
      return
    }

    do {
      try await asyncFunction(for: viewModel.searchCity(city: query))
    } catch {
      state.errorMessage = error.localizedDescription
    }
  }

  private func observeFlows() {
    guard let viewModel else { return }

    observationTasks.append(
      Task { [weak self] in
        do {
          for try await loading in asyncSequence(for: viewModel.loading) {
            self?.state.isLoading = loading.boolValue
          }
        } catch {
          // KMP flow observation ended unexpectedly.
        }
      }
    )

    observationTasks.append(
      Task { [weak self] in
        do {
          for try await error in asyncSequence(for: viewModel.searchError) {
            self?.state.errorMessage = error.isEmpty ? nil : error
          }
        } catch {
          // KMP flow observation ended unexpectedly.
        }
      }
    )

    observationTasks.append(
      Task { [weak self] in
        do {
          for try await cities in asyncSequence(for: viewModel.searchCityResult) {
            self?.state.searchResults = cities
          }
        } catch {
          // KMP flow observation ended unexpectedly.
        }
      }
    )
  }

  deinit {
    searchTask?.cancel()
    observationTasks.forEach { $0.cancel() }
  }
}
