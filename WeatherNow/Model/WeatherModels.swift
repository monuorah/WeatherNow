//
//  WeatherModels.swift
//  PhotoLibrary
//
//  Created by Muna Onuorah on 10/19/25.
//

import Foundation

enum WeatherType: String, Codable, CaseIterable {
    case sunny = "Sunny"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case foggy = "Foggy"
    
    var iconName: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .foggy: return "cloud.fog.fill"
        }
    }
    
    // Maps Open-Meteo weather codes to our weather types
    static func from(weatherCode: Int) -> WeatherType {
        switch weatherCode {
        // Clear sky
        case 0, 1:
            return .sunny
        // Fog
        case 45, 48:
            return .foggy
        // Rain codes (drizzle, rain, freezing rain)
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            return .rainy
        // Snow codes
        case 71, 73, 75, 77, 85, 86:
            return .snowy
        default:
            return .sunny
        }
    }
}

struct WeatherResponse: Codable {
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather
    let timezone: String
}

struct CurrentWeather: Codable {
    let temperature2m: Double
    let weatherCode: Int
    let precipitation: Double
    
    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
        case precipitation
    }
}

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

struct GeocodingResult: Codable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let admin1: String?
    
    var displayName: String {
        if let admin1 = admin1 {
            return "\(name), \(admin1), \(country)"
        }
        return "\(name), \(country)"
    }
}

struct WeatherData: Identifiable {
    let id = UUID()
    let cityName: String
    let country: String
    let temperature: Double
    let weatherType: WeatherType
    let weatherCode: Int
    let precipitation: Double
    
    var temperatureString: String {
        return String(format: "%.0f°C", temperature)
    }
    
    var precipitationString: String {
        return String(format: "Rain: %.0f%%", precipitation)
    }
}
