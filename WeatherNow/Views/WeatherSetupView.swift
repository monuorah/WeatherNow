//
//  WeatherSetupView.swift
//  PhotoLibrary
//
//  Created by Muna Onuorah on 10/19/25.
//

import Foundation
import SwiftUI


struct WeatherSetupView: View {
    @Environment(PhotoStore.self) private var photoStore
    @Environment(WeatherSettings.self) private var weatherSettings
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Assign Weather Photos")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Select a photo for each weather type. These photos will be displayed when you search for weather.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(WeatherType.allCases, id: \.self) { weatherType in
                            WeatherTypeCard(weatherType: weatherType)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Set Weather Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!weatherSettings.allWeatherTypesSet)
                }
            }
        }
    }
}

struct WeatherTypeCard: View {
    let weatherType: WeatherType
    @Environment(PhotoStore.self) private var photoStore
    @Environment(WeatherSettings.self) private var weatherSettings
    @State private var showingPhotoPicker = false
    
    var assignedPhoto: Photo? {
        guard let photoID = weatherSettings.getPhotoID(for: weatherType) else {
            return nil
        }
        return photoStore.photos.first { $0.id == photoID }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                
                if let photo = assignedPhoto, let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: weatherType.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Tap to Set")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if weatherSettings.hasPhoto(for: weatherType) {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 22, height: 22)
                                )
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .onTapGesture {
                showingPhotoPicker = true
            }
            
            Text(weatherType.rawValue)
                .font(.headline)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerForWeather(weatherType: weatherType)
        }
    }
}

struct PhotoPickerForWeather: View {
    let weatherType: WeatherType
    @Environment(PhotoStore.self) private var photoStore
    @Environment(WeatherSettings.self) private var weatherSettings
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if photoStore.photos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Photos Available")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Add photos to your library first")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 150)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(photoStore.photos) { photo in
                            PhotoSelectCard(photo: photo, weatherType: weatherType)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Photo for \(weatherType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PhotoSelectCard: View {
    let photo: Photo
    let weatherType: WeatherType
    @Environment(WeatherSettings.self) private var weatherSettings
    @Environment(\.dismiss) private var dismiss
    
    var isSelected: Bool {
        weatherSettings.getPhotoID(for: weatherType) == photo.id
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .cornerRadius(8)
                }
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 3)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 25, height: 25)
                                )
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            weatherSettings.setPhoto(photo.id, for: weatherType)
            dismiss()
        }
    }
}

#Preview {
    WeatherSetupView()
        .environment(PhotoStore())
        .environment(WeatherSettings())
}
