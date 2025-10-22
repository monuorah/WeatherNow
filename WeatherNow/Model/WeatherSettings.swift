//
//  WeatherSettings.swift
//  WeatherNow
//
//  Created by Muna Onuorah on 10/19/25.
//

import Foundation

@Observable
class WeatherSettings {
    var weatherPhotoAssignments: [String: UUID] = [:]
    
    init() {
        loadSettings()
    }
    
    var allWeatherTypesSet: Bool {
        return WeatherType.allCases.allSatisfy { weatherType in
            weatherPhotoAssignments[weatherType.rawValue] != nil
        }
    }
    
    func getPhotoID(for weatherType: WeatherType) -> UUID? {
        return weatherPhotoAssignments[weatherType.rawValue]
    }
    
    func setPhoto(_ photoID: UUID, for weatherType: WeatherType) {
        weatherPhotoAssignments[weatherType.rawValue] = photoID
        saveSettings()
    }
    
    func hasPhoto(for weatherType: WeatherType) -> Bool {
        return weatherPhotoAssignments[weatherType.rawValue] != nil
    }
    
    var missingWeatherTypes: [WeatherType] {
        return WeatherType.allCases.filter { !hasPhoto(for: $0) }
    }
    
    private func saveSettings() {
        // Convert UUID to String for storage
        let stringDict = weatherPhotoAssignments.mapValues { $0.uuidString }
        if let encoded = try? JSONEncoder().encode(stringDict) {
            UserDefaults.standard.set(encoded, forKey: "WeatherPhotoAssignments")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "WeatherPhotoAssignments"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            // Convert String back to UUID
            weatherPhotoAssignments = decoded.compactMapValues { UUID(uuidString: $0) }
        }
    }
    
    func resetAllAssignments() {
        weatherPhotoAssignments.removeAll()
        saveSettings()
    }
}

