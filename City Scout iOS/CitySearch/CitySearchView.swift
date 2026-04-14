//
//  CitySearchView.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 12/04/2026.
//
import SwiftUI
import CityScoutShared

struct CitySearchView: View {
  @StateObject private var store = SearchCityStore()

  private var searchTextField: some View {
    TextField(
      "Search for a city",
      text: Binding(
        get: { store.state.query },
        set: { store.setQuery($0) }
      )
    )
      .textFieldStyle(.plain)
      .padding(.horizontal, 14)
      .frame(minHeight: 44)
      .background(Color(.systemBackground))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(.secondary.opacity(0.3), lineWidth: 1)
      )
      .padding()
  }

  @ViewBuilder
  private var resultView: some View {
    if let error = store.state.errorMessage, !error.isEmpty, !store.state.query.isEmpty {
      VStack {
        Text(error)
          .foregroundStyle(.red)
        Button("Retry") {
          store.retrySearch()
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
        Spacer()
      }
    } else if store.state.isLoading && store.state.searchResults.isEmpty {
      VStack {
        ProgressView("Searching...")
        Spacer()
      }
    } else {
      List(store.state.searchResults, id: \.self) { city in
        NavigationLink(destination: CityWeatherView(city: city)) {
          VStack(alignment: .leading) {
            Text(city.name)
            Text(city.country)
              .font(.footnote)
          }
        }
      }
    }
  }

  var body: some View {
    VStack {
      searchTextField
      resultView
    }
    .navigationTitle("Search For a City")
  }
}

#Preview {
  CitySearchView()
}
