//
//  CurrentWeatherView.swift
//  CWK2Template
//
//  Created by Sithum Uthsara on 01/01/2024.
//

import SwiftUI

struct WeatherMainView: View {
    // State variable to animate gradient
    @State private var animateGradient = false
    @State private var randomStartPoint: UnitPoint = .topLeading
    @State private var randomEndPoint: UnitPoint = .bottomTrailing
    
    // Function for background animation
    private func generateRandomPoint() -> UnitPoint {
        let randomX = CGFloat.random(in: 0...1)
        let randomY = CGFloat.random(in: 0...1)
        return UnitPoint(x: randomX, y: randomY)
    }
    // Function for Background animation
    private func startGradientAnimation() {
        DispatchQueue.main.async {
            randomStartPoint = generateRandomPoint()
            randomEndPoint = generateRandomPoint()
            animateGradient.toggle()
        }
    }
    
    @EnvironmentObject var location: LocationModel
    
    struct HourlyData: Identifiable, Codable {
        var id = UUID() // Unique identifier for each item in ForEach
        var dateTime: String = ""
        var temperature: String = ""
        var description: String = ""
        var icon: String = ""
    }
    
    struct DailyData: Identifiable, Codable {
        var id = UUID() // Unique identifier for each item in ForEach
        var dateTime: String = ""
        var description: String = ""
        var day: String = ""
        var night: String = ""
        var icon: String = ""
    }
    
    // State variables to store fetched weather data
    @State private var hourlyTemperatures: [HourlyData] = []
    @State private var dailyTemperatures: [DailyData] = []
    
    // Fetch the weather data for hourly and daily forecasts
    private func fetchWeatherData() async {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(location.currentLocation.latitude)&lon=\(location.currentLocation.longitude)&appid=5ef0134ce82b0f3a0ea4e46e125e037d"
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")  // Print if URL is invalid
            return
        }
        
        do {
            // Fetch the data using URLSession with async/await
            let (data, _) = try await URLSession.shared.data(from: url)
            print("Data received: \(data)") // Print received data
            
            // Parse the JSON response
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Failed to parse JSON.")
                return
            }
            print("JSON Object: \(jsonObject)") // Print parsed JSON object
            
            // Hourly weather data (for the next 48 hours)
            if let hourly = jsonObject["hourly"] as? [[String: Any]] {
                print("Hourly data found: \(hourly)") // Print if hourly data exists
                
                var hourlyDataList: [HourlyData] = []
                
                for data in hourly {
                    var hourlyData = HourlyData()
                    if let dt = data["dt"] as? Double {
                        let date = Date(timeIntervalSince1970: dt)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh:mm a"
                        hourlyData.dateTime = formatter.string(from: date)
                    }
                    
                    if let temp = data["temp"] as? Double {
                        let temp = temp - 273.15
                        hourlyData.temperature = String(format: "%.0f", temp) // Round temperature
                    }
                    
                    if let weatherArray = data["weather"] as? [[String: Any]],
                       let firstWeather = weatherArray.first,
                       let description = firstWeather["description"] as? String,
                       let icon = firstWeather["icon"] as? String {
                        
                        hourlyData.description = description
                        hourlyData.icon = icon
                    }
                    
                    hourlyDataList.append(hourlyData)
                }
                
                self.hourlyTemperatures = hourlyDataList
                print("Hourly temperatures parsed: \(hourlyDataList)") // Print parsed hourly temperatures
            } else {
                print("Hourly data not found in response.") // Print if no hourly data is found
            }
            
            // Daily weather data (for the next 7 days)
            if let daily = jsonObject["daily"] as? [[String: Any]] {
                print("Daily data found: \(daily)") // Print if daily data exists
                
                var dailyDataList: [DailyData] = []
                
                for data in daily {
                    var dailyData = DailyData()
                    
                    if let dt = data["dt"] as? Double {
                        let date = Date(timeIntervalSince1970: dt)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "EEEE" // Day name
                        dailyData.dateTime = formatter.string(from: date)
                    }
                    
                    if let temp = data["temp"] as? [String: Any] {
                        if let dayTemp = temp["day"] as? Double {
                            dailyData.day = String(format: "%.0f", dayTemp - 273.15)
                        }
                        if let nightTemp = temp["night"] as? Double {
                            dailyData.night = String(format: "%.0f", nightTemp - 273.15)
                        }
                    }
                    
                    if let weatherArray = data["weather"] as? [[String: Any]],
                       let firstWeather = weatherArray.first,
                       let description = firstWeather["description"] as? String,
                       let icon = firstWeather["icon"] as? String {
                        
                        dailyData.description = description
                        dailyData.icon = icon // Assuming `dailyData` has an `icon` property
                    }
                    
                    dailyDataList.append(dailyData)
                }
                
                self.dailyTemperatures = dailyDataList
                print("Daily temperatures parsed: \(dailyDataList)") // Print parsed daily temperatures
            } else {
                print("Daily data not found in response.") // Print if no daily data is found
            }
            
        } catch {
            print("Error fetching weather data: \(error)")  // Print error if the request fails
        }
    }
    
    // MARK: - View
    
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
            
            
            // ScrollView to make everything scrollable
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // Current Weather View
                    CurrentWeatherView()
                    
                    // Hourly Forecast View
                    VStack {
                        Text("Hourly Forecast")
                            .bold(true)
                            .font(.headline) // Use a standard font style for emphasis
                            .padding() // Simplified padding
                            .frame(maxWidth: 350, minHeight: 30) // Ensures full width and consistent height
                            .background(Color.white.opacity(0.3)) // Background color with opacity
                            .cornerRadius(10) // Rounded corners for better aesthetics
                            .shadow(radius: 5) // Adds a shadow for a more modern look
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(hourlyTemperatures) { temp in
                                    VStack {
                                        Text("\(temp.temperature)°C")
                                            .font(.title2)
                                            .bold()
                                        Text(temp.dateTime)
                                            .font(.caption)
                                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/" + temp.icon + "@2x.png")) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                            case .failure:
                                                Image(systemName: "thermometer.sun.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 50, height: 50)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        Text(temp.description)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .bold()
                                    }
                                    .padding()
                                    .frame(width: 140, height: 150)
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 0)
                                    )
                                    .font(.headline) // Use a standard font style for emphasis
                                    .padding() // Simplified padding
                                    .frame(maxWidth: 320, minHeight: 30) // Ensures full width and consistent height
                                    .background(Color.white.opacity(0.2)) // Background color with opacity
                                    .cornerRadius(10) // Rounded corners for better aesthetics
                                    .shadow(radius: 5) // Adds a shadow for a more modern look
                                    
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    
                    // Daily Forecast View
                    VStack {
                        Text("Daily Forecast")
                            .bold()
                            .font(.headline) // Use a standard font style for emphasis
                            .padding() // Simplified padding
                            .frame(maxWidth: 350, minHeight: 30) // Ensures full width and consistent height
                            .background(Color.white.opacity(0.3)) // Background color with opacity
                            .cornerRadius(10) // Rounded corners for better aesthetics
                            .shadow(radius: 5) // Adds a shadow for a more modern look
                        
                        
                        ForEach(dailyTemperatures) { temp in
                            HStack {
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/" + temp.icon + "@2x.png")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                    case .failure:
                                        Image(systemName: "thermometer.sun.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(temp.dateTime)
                                        .font(.title3)
                                        .bold()
                                    Text(temp.description)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                VStack {
                                    Text("Day: \(temp.day)°C")
                                    Text("Night: \(temp.night)°C")
                                }
                                .font(.body)
                            }
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(8)
                            .frame(width: 350, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.6), lineWidth: 0)
                            )
                            
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 18)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 10)
                .onAppear {
                    // Fetch the weather data when the view appears
                    Task {
                        await fetchWeatherData()
                    }
                }
            }
        }
    }
}

