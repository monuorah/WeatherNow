//
//  WeatherViewModel.swift
//  PhotoLibrary
//
//  Created by Muna Onuorah on 10/19/25.
//

import Foundation

@Observable
class WeatherViewModel {
    var searchQuery: String = ""
    var currentWeatherData: WeatherData?
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    
    private let apiService = WeatherAPIService.shared
    
    @MainActor
    func searchWeather() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a city name"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        showError = false
        currentWeatherData = nil
        
        do {
            let (city, weatherResponse) = try await apiService.getWeatherForCity(cityName: searchQuery)
            
            let weatherType = WeatherType.from(weatherCode: weatherResponse.current.weatherCode)
            
            currentWeatherData = WeatherData(
                cityName: city.name,
                country: city.country,
                temperature: weatherResponse.current.temperature2m,
                weatherType: weatherType,
                weatherCode: weatherResponse.current.weatherCode,
                precipitation: weatherResponse.current.precipitation
            )
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func clearWeather() {
        currentWeatherData = nil
        errorMessage = nil
        showError = false
    }
    
    @MainActor
    func retrySearch() async {
        await searchWeather()
    }
}
