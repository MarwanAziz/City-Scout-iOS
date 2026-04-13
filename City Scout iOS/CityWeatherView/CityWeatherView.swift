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
  var body: some View {
    Text(city.name + " " + city.country)
  }
}
