//
//  WeatherModels.swift
//  WeatherNow
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
    // WMO Weather interpretation codes (WW)
    static func from(weatherCode: Int) -> WeatherType {
        switch weatherCode {
        // Clear sky (0), Mainly clear (1), Partly cloudy (2), Overcast (3)
        case 0, 1, 2, 3:
            return .sunny
        // Fog (45, 48)
        case 45, 48:
            return .foggy
        // Rain codes: Drizzle (51, 53, 55), Freezing Drizzle (56, 57),
        // Rain (61, 63, 65), Freezing Rain (66, 67), Rain showers (80, 81, 82)
        // Thunderstorm (95), Thunderstorm with hail (96, 99)
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99:
            return .rainy
        // Snow codes: Snow fall (71, 73, 75), Snow grains (77), Snow showers (85, 86)
        case 71, 73, 75, 77, 85, 86:
            return .snowy
        // Default to sunny for any unknown codes
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
        return String(format: "Precipitation: %.1f mm", precipitation)
    }
}
