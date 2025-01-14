//
//  CurrentWeatherView.swift
//  CWK2Template
//
//  Created by Sithum Uthsara on 01/01/2024.
//

import SwiftUI

struct VisitedPlacesView: View {
    
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
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            // Dynamic Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.9),
                    Color.cyan.opacity(0.5),
                    Color.blue.opacity(0.6)                ]),
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
            
            VStack(spacing: 20) {
                // Adjust spacing here
                Spacer()
                Text("Weather Locations in Database")
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                List {
                    ForEach(location.locations) { locationData in
                        VStack(alignment: .leading) {
                            Text(locationData.name)
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("Lat: \(locationData.latitude), Lon: \(locationData.longitude)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 5)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding(.horizontal) // Adjust horizontal padding
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let locationToDelete = location.locations[index]
            location.deleteLocation(locationToDelete)
        }
    }
}
