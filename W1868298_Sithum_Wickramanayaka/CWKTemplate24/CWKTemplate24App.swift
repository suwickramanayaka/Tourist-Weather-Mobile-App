//
//  CWKTemplate24App.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

@main
struct CWKTemplate24App: App {
    // MARK:  create a StateObject - weatherMapPlaceViewModel and inject it as an environmentObject.
    
    @StateObject var location = LocationModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(location)
        }
    }
}
