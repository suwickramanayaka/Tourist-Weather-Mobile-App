import SwiftUI
import MapKit

struct MapViewContainer: View {
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
            Image("sky")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
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
                .padding(.top, 120)
                
                Text("Top 5 Tourist Attractions in \(location.currentLocation.name)")
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(5)
                    .padding(.top, 15)
                    .bold()
                
                List(location.topLocations) { place in
                    HStack {
                        Image(systemName: "mappin.and.ellipse.circle.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                        
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

// Define the `Location` model and related data structures
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
