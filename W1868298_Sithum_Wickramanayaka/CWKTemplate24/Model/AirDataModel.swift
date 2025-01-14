//
//  AirDataModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation

/* Code for AirDataModel Struct */

struct AirDataModel: Codable{
    
    // MARK:  list of attributes to map response from openweather pollution api
    var id = UUID()
    let lat, lon: Double
    let dt: Int
    let so2: Double
    let no2: Double
    let voc: Double
    let pm: Double
}
