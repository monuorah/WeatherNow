//
//  WeatherView.swift
//  WeatherNow
//
//  Created by Muna Onuorah on 10/19/25.
//

import Foundation
import SwiftUI


struct WeatherView: View {
    @State private var viewModel = WeatherViewModel()
    @Environment(PhotoStore.self) private var photoStore
    @Environment(WeatherSettings.self) private var weatherSettings
    @State private var showingSetup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !weatherSettings.allWeatherTypesSet {
                    WeatherSetupRequiredView(showingSetup: $showingSetup)
                } else if viewModel.currentWeatherData == nil {
                    WeatherSearchView(viewModel: viewModel)
                } else {
                    WeatherResultView(viewModel: viewModel)
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if weatherSettings.allWeatherTypesSet {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            showingSetup = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSetup) {
                WeatherSetupView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {
                    viewModel.showError = false
                }
                Button("Retry") {
                    Task {
                        await viewModel.retrySearch()
                    }
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

struct WeatherSetupRequiredView: View {
    @Binding var showingSetup: Bool
    @Environment(WeatherSettings.self) private var weatherSettings
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                Text("Default Images Not Set")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("You need to set images for all weather types before you can search for weather.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                showingSetup = true
            }) {
                Text("Set Images")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            if !weatherSettings.missingWeatherTypes.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Missing:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(weatherSettings.missingWeatherTypes, id: \.self) { type in
                        HStack {
                            Image(systemName: type.iconName)
                            Text(type.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct WeatherSearchView: View {
    @Bindable var viewModel: WeatherViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                Text("Search for Weather")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter a city name to see the weather and your assigned photo")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack {
                TextField("Enter city name...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .focused($isSearchFocused)
                    .onSubmit {
                        Task {
                            await viewModel.searchWeather()
                        }
                    }
                    .autocorrectionDisabled()
                
                Button(action: {
                    Task {
                        await viewModel.searchWeather()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(width: 60, height: 44)
                    } else {
                        Text("Search")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 44)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .disabled(viewModel.isLoading || viewModel.searchQuery.isEmpty)
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct WeatherResultView: View {
    @Bindable var viewModel: WeatherViewModel
    @Environment(PhotoStore.self) private var photoStore
    @Environment(WeatherSettings.self) private var weatherSettings
    
    var assignedPhoto: Photo? {
        guard let weatherData = viewModel.currentWeatherData,
              let photoID = weatherSettings.getPhotoID(for: weatherData.weatherType) else {
            return nil
        }
        return photoStore.photos.first { $0.id == photoID }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    TextField("Enter city name...", text: $viewModel.searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task {
                                await viewModel.searchWeather()
                            }
                        }
                        .autocorrectionDisabled()
                    
                    Button(action: {
                        Task {
                            await viewModel.searchWeather()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(width: 60, height: 44)
                        } else {
                            Text("Search")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 44)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.searchQuery.isEmpty)
                }
                .padding()
                
                if let weatherData = viewModel.currentWeatherData {
                    VStack(spacing: 20) {
                        Text(weatherData.cityName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(weatherData.country)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if let photo = assignedPhoto, let image = photo.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .clipped()
                                .cornerRadius(16)
                                .padding(.horizontal)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 300)
                                
                                VStack {
                                    Image(systemName: weatherData.weatherType.iconName)
                                        .font(.system(size: 80))
                                        .foregroundColor(.gray)
                                    Text("Photo not found")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text(weatherData.temperatureString)
                            .font(.system(size: 72, weight: .thin))
                        
                        HStack(spacing: 10) {
                            Image(systemName: weatherData.weatherType.iconName)
                                .font(.title)
                            Text(weatherData.weatherType.rawValue)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text(weatherData.precipitationString)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .accessibility(label: Text("Weather results for \(viewModel.currentWeatherData?.cityName ?? "")"))
    }
}

#Preview {
    WeatherView()
        .environment(PhotoStore())
        .environment(WeatherSettings())
}
