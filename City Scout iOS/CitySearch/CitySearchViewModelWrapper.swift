//
//  CitySearchViewModelWrapper.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 12/04/2026.
//

import SwiftUI
import SharedResources
import CityScoutShared
internal import Combine
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCombine

class CitySearchViewModelWrapper: ObservableObject {
  private var viewModel: SearchCityViewModel?
  @Published var searchResults: [SearchCityResult] = []
  @Published var isLoading: Bool = false
  @Published var isError: String? = nil
  @Published var searchText: String = ""
  private var cancellables: Set<AnyCancellable> = []

  fileprivate func initialiseViewModel() {
    let resources = SharedResources.shared
    resources
      .initialise(
        rapidApiKey: "68999f7a20mshffaf2134c1e9edfp17598ejsn31fb20bd0572",
        weatherApiKey: "e5a0ae782b414ae7b9000554260404"
      )
    
    viewModel = try? resources.createSearchCityViewModel()
  }

  fileprivate func observeIsLoading() {
    guard let viewModel else {
      fatalError("SearchCityViewModel is nil")
    }
    let publisher = createPublisher(for: viewModel.loading)
    publisher
      .subscribe(on: DispatchQueue.global(qos: .background))
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          print("publisher completed: \(completion)")
        },
        receiveValue: {[weak self] loading in
          self?.isLoading = loading.boolValue
        }
      )
      .store(in: &cancellables)
  }

  fileprivate func observeError() {
    guard let viewModel else {
      fatalError("SearchCityViewModel is nil")
    }
    let publisher = createPublisher(for: viewModel.searchError)
    publisher
      .subscribe(on: DispatchQueue.global(qos: .background))
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          print("publisher completed: \(completion)")
        },
        receiveValue: {[weak self] error in
          self?.isError = error.isEmpty ? nil : error
        }
      )
      .store(in: &cancellables)
  }

  fileprivate func observeSearchResults() {
    guard let viewModel else {
      fatalError("SearchCityViewModel is nil")
    }
    let publisher = createPublisher(for: viewModel.searchCityResult)
    publisher
      .subscribe(on: DispatchQueue.global(qos: .background))
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          print("publisher completed: \(completion)")
        },
        receiveValue: {[weak self] cities in
          self?.searchResults = cities
        }
      )
      .store(in: &cancellables)
  }

  fileprivate func observeSearch() {
    $searchText
      .subscribe(
        on: DispatchQueue.global(qos: .background)
      )
      .receive(
        on: DispatchQueue.global(qos: .background)
      )
      .sink(
        receiveCompletion: { completed in

      }, receiveValue: {[weak self] value in
        Task {
          guard let self, let viewModel = self.viewModel else {
            return
          }
          try? await asyncFunction(
            for: viewModel.searchCity(
              city: value
            )
          )
        }
      }
      ).store(in: &cancellables)

  }

  init() {
    initialiseViewModel()
    observeSearch()
    observeIsLoading()
    observeSearchResults()
    observeError()
  }
}
