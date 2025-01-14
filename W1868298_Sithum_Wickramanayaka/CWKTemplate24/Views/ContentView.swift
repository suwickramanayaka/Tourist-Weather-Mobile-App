//
//  CurrentWeatherView.swift
//  CWK2Template
//
//  Created by Sithum Uthsara on 01/01/2024.
//

import SwiftUI

struct ContentView: View {
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
    
    
    // State variable to track the selected tab
    @State private var selectedTab = 2 // Default to the "Now" tab
    @State private var searchText = "" // State for managing the search text
    @EnvironmentObject var location: LocationModel // Specify the module name for your custom Location class
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var locationCoordinates: (latitude: Double, longitude: Double)?
    @State private var showAlert_location_exists = false
    @State private var showAlert_new_location_to_database = false
    @State private var showAlert_invalid_location = false
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 0) { // Use spacing to control gaps
            // App Bar with Background Image
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
                .scaledToFill()
                .frame(height: 70) // Set the height of the app bar
                .edgesIgnoringSafeArea(.top)
                .ignoresSafeArea()
                .animation(
                    Animation.linear(duration: 30).repeatForever(autoreverses: true),
                    value: animateGradient
                )
                .onAppear {
                    startGradientAnimation()
                }
                
                // Search Box
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for a city", text: $searchText)
                        .frame(width: 300, height: 20)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.system(size: 18))
                        .onSubmit {
                            isLoading = true
                            
                            Task {
                                do {
                                    if location.doesLocationExist(locationName: searchText) {
                                        showAlert_location_exists = true
                                    } else {
                                        location.getCoordinates(for: searchText) { coordinate, error in
                                            if error != nil {
                                                showAlert_invalid_location = true
                                            } else if let coordinate = coordinate {
                                                locationCoordinates = (coordinate.latitude, coordinate.longitude)
                                                showAlert_new_location_to_database = true
                                            }
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        isLoading = false
                                    }
                                } catch {
                                    print("Error: \(error)")
                                    
                                    DispatchQueue.main.async {
                                        isLoading = false
                                    }
                                }
                            }
                        }
                }
                .padding(6)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.5), radius: 5)
            }
            
            // Main Content
            TabView(selection: $selectedTab) {
                
                MapViewContainer()
                    .tabItem {
                        Label("Map", systemImage: "map")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.white)
                    }
                    .tag(1)
                WeatherMainView()
                    .tabItem {
                        Label("Now", systemImage: "location.fill")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.white)
                    }
                    .tag(2)
                
                VisitedPlacesView()
                    .tabItem {
                        Label("Places", systemImage: "list.bullet")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.white)
                    }
                    .tag(3)
            }.padding(.top, 10)
                .navigationBarTitleDisplayMode(.inline)
            
        }
        .alert("Location Exists", isPresented: $showAlert_location_exists) {
            Button("OK") {
                // Handle existing location case
            }
        } message: {
            Text("The location \(searchText) exists in the saved list.")
        }
        .alert("Location Will Be Added", isPresented: $showAlert_new_location_to_database) {
            Button("OK") {
                if let coordinates = locationCoordinates {
                    location.addNewLocation(name: searchText, latitude: coordinates.latitude, longitude: coordinates.longitude)
                } else {
                    showAlert_invalid_location = true
                }
            }
        } message: {
            Text("The location \(searchText) will be added to the database.")
        }
        .alert("Invalid Location", isPresented: $showAlert_invalid_location) {
            Button("OK") {
                // Handle invalid location case
            }
        } message: {
            Text("The location \(searchText) is invalid or could not be found.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WeatherMapPlaceViewModel())
    }
}
