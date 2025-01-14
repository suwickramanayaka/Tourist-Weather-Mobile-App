//
//  CurrentWeatherView.swift
//  CWK2Template
//
//  Created by Sithum Uthsara on 01/01/2024.
//

import SwiftUI
import MapKit

struct MapViewContainer: View {
    // State variable to animate gradient
    @State private var animateGradient = false
    @State private var randomStartPoint: UnitPoint = .topLeading
    @State private var randomEndPoint: UnitPoint = .bottomTrailing
    
    private func generateRandomPoint() -> UnitPoint {
        let randomX = CGFloat.random(in: 0...1)
        let randomY = CGFloat.random(in: 0...1)
        return UnitPoint(x: randomX, y: randomY)
    }
    
    private func startGradientAnimation() {
        DispatchQueue.main.async {
            randomStartPoint = generateRandomPoint()
            randomEndPoint = generateRandomPoint()
            animateGradient.toggle()
        }
    }
    
    @EnvironmentObject var location: LocationModel
    
    // A function that fetches the tourist attractions based on the current location
    private func fetchTouristAttractions() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tourist Attraction"
        
        // Set the region based on the current location
        let coordinate = CLLocationCoordinate2D(latitude: location.currentLocation.latitude, longitude: location.currentLocation.longitude)
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("No results found.")
                return
            }
            
            // Get the top 5 places
            let topPlaces = response.mapItems.prefix(5).map { mapItem in
                LocationModel.TopLocation(
                    name: mapItem.name ?? "Unknown Place",
                    latitude: mapItem.placemark.coordinate.latitude,
                    longitude: mapItem.placemark.coordinate.longitude
                )
            }
            
            DispatchQueue.main.async {
                location.topLocations = Array(topPlaces)
            }
        }
    }
    
    var body: some View {
        ZStack {
            
            // Dynamic Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.9),
                    Color.cyan.opacity(0.5),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: animateGradient ? randomStartPoint : randomEndPoint,
                endPoint: animateGradient ? randomEndPoint : randomStartPoint
            )
            .ignoresSafeArea()
            .animation(
                Animation.linear(duration: 30).repeatForever(autoreverses: true),
                value: animateGradient
            )
            .onAppear {
                startGradientAnimation()
            }
            
            VStack {
                Map(coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: location.currentLocation.latitude,
                            longitude: location.currentLocation.longitude
                        ),
                        latitudinalMeters: 10000,
                        longitudinalMeters: 10000
                    )
                ), annotationItems: location.topLocations) { place in
                    MapMarker(
                        coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                        tint: .red
                    )
                }
                .frame(height: 350)
                //.padding(.top, 120)
                
                Text("Top 5 Tourist Attractions in \(location.currentLocation.name)")
                    .font(.headline) // Use a standard font style for emphasis
                    .padding() // Simplified padding
                    .frame(maxWidth: 350, minHeight: 30) // Ensures full width and consistent height
                    .background(Color.white.opacity(0.2)) // Background color with opacity
                    .cornerRadius(10) // Rounded corners for better aesthetics
                    .shadow(radius: 5) // Adds a shadow for a more modern look
                
                List(location.topLocations) { place in
                    HStack {
                        Image(systemName: "mappin.and.ellipse.circle.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        
                        
                        Text(place.name)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .onAppear {
                fetchTouristAttractions()
            }
            .onChange(of: location.currentLocation) { _ in
                fetchTouristAttractions()
            }
        }
    }
}

// Define the ⁠ Location ⁠ model and related data structures
class Location: ObservableObject {
    @Published var currentLocation: CurrentLocation
    @Published var topLocations: [TopLocation] = []
    
    init(currentLocation: CurrentLocation) {
        self.currentLocation = currentLocation
    }
    
    struct CurrentLocation {
        var name: String
        var latitude: Double
        var longitude: Double
    }
    
    struct TopLocation: Identifiable {
        var id = UUID()
        var name: String
        var latitude: Double
        var longitude: Double
    }
}

// Preview example
struct MapViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        MapViewContainer()
            .environmentObject(
                Location(currentLocation: Location.CurrentLocation(name: "Sample City", latitude: 37.7749, longitude: -122.4194))
            )
    }
}
