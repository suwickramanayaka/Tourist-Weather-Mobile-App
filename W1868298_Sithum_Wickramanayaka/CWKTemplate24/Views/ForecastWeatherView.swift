//
//  CurrentWeatherView.swift
//  CWK2Template
//
//  Created by Sithum Uthsara on 01/01/2024.
//

import SwiftUI

struct ForecastWeatherView: View {
    
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
        let urlString =  "https://api.openweathermap.org/data/3.0/onecall?lat=\(location.currentLocation.latitude)&lon=\(location.currentLocation.longitude)&appid=5ef0134ce82b0f3a0ea4e46e125e037d"
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
            Image("BG") // Replace "BG" with your asset's image name
                .resizable()
                .scaledToFill() // Ensures the image covers the entire area
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) // Set the image to cover the full screen
                .edgesIgnoringSafeArea(.all) // Ensures the image extends beyond the safe areas (top, bottom, etc.)
            
            VStack {
                Text("Hourly Forecast Weather for \(location.currentLocation.name)").bold()
                // Upper part: Horizontally scrollable hourly temperature
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(hourlyTemperatures) { temp in
                            VStack {
                                Text("\(temp.temperature)°C")
                                    .font(.title2)
                                    .bold()
                                Text(temp.dateTime)
                                    .font(.title2)
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/"+String(temp.icon)+"@2x.png")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Show a loading spinner while the image is loading
                                    case .success(let image):
                                        image
                                            .resizable() // Make the image resizable
                                            .scaledToFit() // Scale the image to fit within the frame
                                            .frame(width: 40, height: 40) // Set the size (width and height)
                                    case .failure:
                                        Image(systemName: "thermometer.sun.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50) // Set the size of the placeholder image
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                Text(temp.description)
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(width: 140, height: 150)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8) // Rounds the corners of the background
                            .overlay(
                                RoundedRectangle(cornerRadius: 8) // Creates a rounded rectangle for the border
                                    .stroke(Color.black.opacity(0.6), lineWidth: 0) // Sets the border color and width
                            )
                            
                            
                        }
                    }
                    .padding()
                }
                
                // Lower part: Vertically scrollable daily temperatures
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(dailyTemperatures) { temp in
                            HStack {
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/"+String(temp.icon)+"@2x.png")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Show a loading spinner while the image is loading
                                    case .success(let image):
                                        image
                                            .resizable() // Make the image resizable
                                            .scaledToFit() // Scale the image to fit within the frame
                                            .frame(width: 40, height: 40) // Set the size (width and height)
                                    case .failure:
                                        Image(systemName: "thermometer.sun.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50) // Set the size of the placeholder image
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                
                                //Spacer().frame(width: 20)
                                
                                VStack(alignment: .leading) {
                                    Text(temp.dateTime)
                                        .font(.title3)
                                        .bold()
                                    Text(temp.description)
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                                //Spacer()
                                VStack {
                                    Text("Day: \(temp.day)°C")
                                    Text("Night: \(temp.night)°C")
                                }
                                .font(.body)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8) // Creates a rounded rectangle for the border
                                    .stroke(Color.black.opacity(0.6), lineWidth: 0) // Sets the border color and width
                            )
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                // Fetch the weather data when the view appears
                Task {
                    await fetchWeatherData()
                }
            }
            .padding(.top, 120)
            .padding(.horizontal, 10)
            .padding(.bottom, 120)
            .onChange(of: location.currentLocation) { _ in
                Task {
                    await fetchWeatherData()
                }
            }
        }
    }
}

//#Preview {
//    ForecastWeatherView()
//        .environmentObject(Location())
//}
