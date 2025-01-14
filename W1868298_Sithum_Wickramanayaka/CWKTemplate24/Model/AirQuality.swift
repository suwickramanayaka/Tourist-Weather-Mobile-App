import Foundation



struct AirQuality: Codable, Identifiable {
    var id = UUID()
    let lat, lon: Double
    let dt: Int
    let so2: Double
    let no2: Double
    let voc: Double
    let pm: Double
}
