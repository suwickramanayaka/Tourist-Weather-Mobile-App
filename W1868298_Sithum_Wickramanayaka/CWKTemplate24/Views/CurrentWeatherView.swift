//
//  CurrentWeatherView.swift
//  CWK2Template
//
//  Created by Sithum Uthsara on 01/01/2024.
//

import SwiftUI

struct CurrentWeatherView: View {
    @EnvironmentObject var location: LocationModel
    
    // State variables to hold the fetched weather data
    @State private var date: String? = nil
    @State private var time: String? = nil
    @State private var weatherDescription: String? = nil
    @State private var feelsLike: String? = nil
    @State private var highTemp: String? = nil
    @State private var lowTemp: String? = nil
    @State private var windspeed: String? = nil
    @State private var humidity: String? = nil
    @State private var pressure: String? = nil
    @State private var so2: String? = nil
    @State private var no2: String? = nil
    @State private var voc: String? = nil
    @State private var pm: String? = nil
    @State private var icon: String? = nil
    
    // Fetch weather data function
    private func fetchWeatherData() async {
        let apiKey = "5ef0134ce82b0f3a0ea4e46e125e037d"
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(location.currentLocation.latitude)&lon=\(location.currentLocation.longitude)&appid=\(apiKey)"
        print("Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Failed to parse JSON or data is nil.")
                return
            }
            
            if let currentWeather = jsonObject["current"] as? [String: Any] {
                if let weatherArray = currentWeather["weather"] as? [[String: Any]] {
                    self.weatherDescription = weatherArray.first?["description"] as? String
                    self.icon = weatherArray.first?["icon"] as? String
                }
                if let feelsLikeKelvin = currentWeather["feels_like"] as? Double {
                    let feelsLikeCelsius = feelsLikeKelvin - 273.15
                    self.feelsLike = String(format: "%.1f", feelsLikeCelsius) + "°C"
                } else {
                    self.feelsLike = "N/A"
                }
                self.highTemp = "\(currentWeather["temp_max"] as? Double ?? 5)°C"
                self.lowTemp = "\(currentWeather["temp_min"] as? Double ?? 1)°C"
                self.windspeed = "\(currentWeather["wind_speed"] as? Double ?? 0) m/s"
                self.humidity = "\(currentWeather["humidity"] as? Int ?? 0)%"
                self.pressure = "\(currentWeather["pressure"] as? Int ?? 0) hPa"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .medium
                self.date = dateFormatter.string(from: Date())
                self.time = dateFormatter.string(from: Date())
            }
            
        } catch {
            print("Error fetching weather data: \(error)")
        }
    }
    
    private func fetchAirData() async {
        print("function called")
        let apiKey = "5ef0134ce82b0f3a0ea4e46e125e037d"
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(location.currentLocation.latitude)&lon=\(location.currentLocation.longitude)&appid=\(apiKey)"
        print("Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Failed to parse JSON or data is nil.")
                return
            }
            
            if let list = jsonObject["list"] as? [[String: Any]], let firstItem = list.first, let components = firstItem["components"] as? [String: Any] {
                self.so2 = "\(components["so2"] as? Double ?? 0.0)"
                self.no2 = "\(components["no2"] as? Double ?? 0.0)"
                self.voc = "\(components["voc"] as? Double ?? 2.0)"
                self.pm = "\(components["pm2_5"] as? Double ?? 0.0)"
            }
            
        } catch {
            print("Error fetching air data: \(error)")
        }
    }
    // MARK: - View
    var body: some View {
        ZStack {
            
            ScrollView {
                VStack(spacing: 16) {
                    Text("\(location.currentLocation.name)")
                        .font(.title)
                        .bold()
                    
                    if let date = date, let time = time {
                        Text("\(date) ")
                            .font(.title2)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    
                    if let feelsLike = feelsLike, let weatherDescription = weatherDescription {
                        ZStack {
                            // Background Box
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.3)) // Background color
                                .frame(width: 350, height: 150) // Adjust box size
                                .shadow(radius: 5)
                            
                            // Content inside the box
                            HStack(spacing: 16) {
                                // Weather Icon
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon ?? "")@2x.png")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Show a loading spinner while the image is loading
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80) // Adjusted icon size
                                    case .failure:
                                        Image(systemName: "thermometer.sun.fill") // Placeholder icon in case of failure
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80) // Placeholder icon size
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .padding(.leading, 16) // Padding for spacing
                                
                                // Weather Information
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(weatherDescription)")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.black)
                                    Text("Feels Like: \(feelsLike)")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing, 16) // Padding for spacing
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        if let highTemp = highTemp, let lowTemp = lowTemp {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 170, height: 100)
                                    .shadow(radius: 5)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "thermometer")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                    Text("H: \(highTemp)")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                    Text("L: \(lowTemp)")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        if let windspeed = windspeed {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 170, height: 100)
                                    .shadow(radius: 5)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "wind")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                    Text("Wind")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                    Text("\(windspeed)")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        if let humidity = humidity {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 170, height: 100)
                                    .shadow(radius: 5)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "humidity.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                    Text("Humidity")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                    Text("\(humidity)")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        if let pressure = pressure {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 170, height: 100)
                                    .shadow(radius: 5)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                    Text("Pressure")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                    Text("\(pressure)")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    Text("Current Air Quality in \(location.currentLocation.name)")
                        .font(.headline) // Use a standard font style for emphasis
                        .padding() // Simplified padding
                        .frame(maxWidth: 350, minHeight: 30) // Ensures full width and consistent height
                        .background(Color.white.opacity(0.3)) // Background color with opacity
                        .cornerRadius(10) // Rounded corners for better aesthetics
                        .shadow(radius: 5) // Adds a shadow for a more modern look
                    
                    HStack {
                        Spacer()
                        
                        if let so2 = so2 {
                            VStack {
                                Image(systemName: "cloud.fog.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.white)
                                Text("SO2").bold().foregroundStyle(.red)
                                Text("\(so2)").bold()
                            }
                        }
                        
                        Spacer()
                        
                        if let no2 = no2 {
                            VStack {
                                Image(systemName: "flame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.white)
                                Text("NO2").bold().foregroundStyle(.red)
                                Text("\(no2)").bold()
                            }
                            
                        }
                        
                        Spacer()
                        
                        if let voc = voc {
                            VStack {
                                Image(systemName: "aqi.medium")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.white)
                                Text("VOC").bold().foregroundStyle(.red)
                                Text("\(voc)").bold()
                            }
                            
                        }
                        
                        Spacer()
                        
                        if let pm = pm {
                            VStack {
                                Image(systemName: "aqi.high")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.white)
                                Text("PM").bold().foregroundStyle(.red)
                                Text("\(pm)").bold()
                            }
                        }
                        
                        Spacer()
                    }.frame(width: 350, height: 140)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(5)
                }
                .padding()
            }
            .onAppear {
                Task {
                    await fetchWeatherData()
                    await fetchAirData()
                }
            }
            .onChange(of: location.currentLocation) { _ in
                Task {
                    await fetchWeatherData()
                    await fetchAirData()
                }
            }
        }
    }
}

//#Preview {
//    CurrentWeatherView()
//        .environmentObject(Location())
//}
