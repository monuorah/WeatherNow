//
//  WeatherAPIService.swift
//  WeatherNow
//
//  Created by Muna Onuorah on 10/19/25.
//

import Foundation

enum WeatherAPIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case cityNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to decode weather data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cityNotFound:
            return "City not found. Please try a different search."
        }
    }
}

class WeatherAPIService {
    static let shared = WeatherAPIService()
    
    private init() {}
    
    func searchCity(query: String) async throws -> [GeocodingResult] {
        // Open-Meteo Geocoding API
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(encodedQuery)&count=5&language=en&format=json"
        
        guard let url = URL(string: urlString) else {
            throw WeatherAPIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
            
            guard let results = response.results, !results.isEmpty else {
                throw WeatherAPIError.cityNotFound
            }
            
            return results
        } catch let error as WeatherAPIError {
            throw error
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw WeatherAPIError.decodingError
        } catch {
            throw WeatherAPIError.networkError(error)
        }
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,precipitation&temperature_unit=celsius&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw WeatherAPIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return response
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw WeatherAPIError.decodingError
        } catch {
            throw WeatherAPIError.networkError(error)
        }
    }
    
    func getWeatherForCity(cityName: String) async throws -> (GeocodingResult, WeatherResponse) {
        // First, search for the city
        let cities = try await searchCity(query: cityName)
        
        guard let firstCity = cities.first else {
            throw WeatherAPIError.cityNotFound
        }
        
        // Then fetch weather for that city
        let weather = try await fetchWeather(latitude: firstCity.latitude, longitude: firstCity.longitude)
        
        return (firstCity, weather)
    }
}

