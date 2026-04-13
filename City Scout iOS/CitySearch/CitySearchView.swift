//
//  CitySearchView.swift
//  City Scout iOS
//
//  Created by Marwan Aziz on 12/04/2026.
//
import SwiftUI
import CityScoutShared

struct CitySearchView: View {
  @StateObject var viewModel = CitySearchViewModelWrapper()

  private var searchTextField: some View {
    TextField("Search for a city", text: $viewModel.searchText)
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

  private var resultView: some View {
    if !(viewModel.isError ?? "").isEmpty,
       !viewModel.searchText.isEmpty {
      AnyView(
        VStack {
          Text(viewModel.isError ?? "")
            .foregroundColor(.red)
          Spacer()
        }
      )
    } else {
      AnyView(
        List(viewModel.searchResults, id: \.self) { city in
          NavigationLink(destination: CityWeatherView(city: city)) {
            VStack(alignment: .leading) {
              Text(city.name)
              Text(city.country)
                .font(.footnote)
            }
          }
        }
      )
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
