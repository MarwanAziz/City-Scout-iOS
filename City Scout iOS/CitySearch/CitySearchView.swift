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

  var body: some View {
    VStack {
      TextField("Search for a city", text: $viewModel.searchText)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
      List(viewModel.searchResults, id: \.self) { city in
        VStack(alignment: .leading) {
          Text(city.name)
          Text(city.country)
            .font(.footnote)
        }
      }
    }
    .navigationTitle("Search For a City")
  }
}

#Preview {
  CitySearchView()
}
