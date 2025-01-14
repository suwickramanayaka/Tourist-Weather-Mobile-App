//
//  LocationModel.swift
//  CWK2Template
//
//  Created by girish lukka on 01/11/2023.
//


import SwiftUI
import CoreLocation

class LocationModel: ObservableObject {
    @AppStorage("savedLocations") private var savedLocationsData: String = ""
    
    @Published var locations: [LocationData] = []
    @Published var topLocations: [TopLocation] = []
    @Published var currentLocation = LocationData(name: "London", latitude: 51.5074, longitude: -0.1278)
    
    struct LocationData: Codable, Identifiable, Equatable {
        var id = UUID()
        var name: String
        var latitude: Double
        var longitude: Double
    }
    
    struct TopLocation: Identifiable, Codable {
        var id = UUID() // Add an ID for List identification
        var name: String
        var latitude: Double
        var longitude: Double
    }
    
    init() {
        loadLocations()
    }
    
    // Save locations to AppStorage
    private func saveLocations() {
        if let encoded = try? JSONEncoder().encode(locations) {
            savedLocationsData = String(data: encoded, encoding: .utf8) ?? ""
        }
    }
    
    // Load locations from AppStorage
    private func loadLocations() {
        if let data = savedLocationsData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([LocationData].self, from: data) {
            locations = decoded
        }
    }
    
    // Check if a location exists by name and perform an action if it does
    func doesLocationExist(locationName: String) -> Bool {
        if let locationData = locations.first(where: { $0.name.lowercased() == locationName.lowercased() }) {
            currentLocation = locationData
            return true
        }
        return false
    }
    
    // Get coordinates for a city name
    func getCoordinates(for cityName: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let error = error {
                completion(nil, error)
            } else if let placemark = placemarks?.first,
                      let location = placemark.location {
                completion(location.coordinate, nil)
            } else {
                completion(nil, NSError(domain: "GeocodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No location found"]))
            }
        }
    }
    
    // Function to add a new location
    func addNewLocation(name: String, latitude: Double, longitude: Double) {
        // Create a new location data object
        let newLocation = LocationData(name: name, latitude: latitude, longitude: longitude)
        
        // Add the new location to the locations array
        locations.append(newLocation)
        
        // Optionally save the locations if using AppStorage or CoreData
        saveLocations()
        currentLocation = newLocation
    }
    
    // Function to delete a specific location
    func deleteLocation(_ locationData: LocationModel.LocationData) {
        if let index = locations.firstIndex(where: { $0.id == locationData.id }) {
            locations.remove(at: index)
            saveLocations()  // Save after deletion
        }
    }
    
    func getLocationData(locationName: String) -> LocationModel.LocationData? {
        return locations.first(where: { $0.name.lowercased() == locationName.lowercased() })
    }
}
