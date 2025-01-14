//
//  WeatherMapViewModel.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

class WeatherMapPlaceViewModel: ObservableObject {
    // MARK:   published variables
    @Published var weatherDataModel: WeatherDataModel?
    @Published var city = "London"
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    init() {
        // MARK:  create Task to load London weather data when the app first launches
        Task {
            do {
                // func gets London on initial run of the program
                try await getCoordinatesForCity()
            }
            catch {
                // Handle errors if necessary
                print("Error loading weather data: \(error)")
            }
        }
    }
    func getCoordinatesForCity() async throws {
        // MARK:  complete the code to get user coordinates for user entered place
        // and specify the map region
        
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.geocodeAddressString(city),
           let location = placemarks.first?.location?.coordinate {
            
            DispatchQueue.main.async {
                self.coordinates = location
                self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
            
            let data = try await loadData(lat: location.latitude, lon: location.longitude )
            print("Weather data loaded: \(String(describing: data.timezone))")
            
        } else {
            // Handle error here if geocoding fails
            print("Error: Unable to find the coordinates for the club.")
        }
    }
    
    func loadData(lat: Double, lon: Double) async throws -> WeatherDataModel {
        // MARK:  add your appid in the url below:
        if let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=5ef0134ce82b0f3a0ea4e46e125e037d") {
            let session = URLSession(configuration: .default)
            
            do {
                let (data, _) = try await session.data(from: url)
                let weatherDataModel = try JSONDecoder().decode(WeatherDataModel.self, from: data)
                
                DispatchQueue.main.async {
                    self.weatherDataModel = weatherDataModel
                    print("weatherDataModel loaded")
                }
                
                // MARK:  The code below is to help you see number of records and different time stamps that has been retrieved as part of api response.
                
                print("MINUTELY")
                if let count = weatherDataModel.minutely?.count {
                    if let firstTimestamp = weatherDataModel.minutely?[0].dt {
                        let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                        let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                        print("First Timestamp: \(formattedFirstDate)")
                    }
                    
                    if let lastTimestamp = weatherDataModel.minutely?[count - 1].dt {
                        let lastDate = Date(timeIntervalSince1970: TimeInterval(lastTimestamp))
                        let formattedLastDate = DateFormatterUtils.shared.string(from: lastDate)
                        print("Last Timestamp: \(formattedLastDate)")
                    }
                } // minute
                
                print("Hourly start")
                
                let hourlyCount = weatherDataModel.hourly.count
                print(hourlyCount)
                if hourlyCount > 0 {
                    let firstTimestamp = weatherDataModel.hourly[0].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                    print("First Hourly Timestamp: \(formattedFirstDate)")
                    print("Temp in first hour: \(weatherDataModel.hourly[0].temp)")
                }
                
                if hourlyCount > 0 {
                    let lastTimestamp = weatherDataModel.hourly[hourlyCount - 1].dt
                    let lastDate = Date(timeIntervalSince1970: TimeInterval(lastTimestamp))
                    let formattedLastDate = DateFormatterUtils.shared.string(from: lastDate)
                    print("Last Hourly Timestamp: \(formattedLastDate)")
                    print("Temp in last hour: \(weatherDataModel.hourly[hourlyCount - 1].temp)")
                }
                
                print("//Hourly Complete")
                
                print("Daily start")
                let dailyCount = weatherDataModel.daily.count
                print(dailyCount)
                
                if dailyCount > 0 {
                    let firstTimestamp = weatherDataModel.daily[0].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                    print("First daily Timestamp: \(formattedFirstDate)")
                    print("Temp for first day: \(weatherDataModel.daily[0].temp)")
                }
                
                if dailyCount > 0 {
                    let firstTimestamp = weatherDataModel.daily[dailyCount-1].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                    print("Last daily Timestamp: \(formattedFirstDate)")
                    print("Temp for last day: \(weatherDataModel.daily[dailyCount-1].temp)")
                }
                print("//daily complete")
                return weatherDataModel
            } catch {
                
                if let decodingError = error as? DecodingError {
                    
                    print("Decoding error: \(decodingError)")
                } else {
                    //  other errors
                    print("Error: \(error)")
                }
                throw error // Re-throw the error to the caller
            }
        } else {
            throw NetworkError.invalidURL
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
    }
    
    
    func loadLocationsFromJSONFile(cityName: String) -> [LocationDataModel]? {
        if let fileURL = Bundle.main.url(forResource: "places", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let allLocations = try decoder.decode([LocationDataModel].self, from: data)
                
                return allLocations
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("File not found")
        }
        return nil
    }
}


