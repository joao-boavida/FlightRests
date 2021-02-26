//
//  ContentView.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            InputView(inputType: .flightCrew)
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Flight Crew")
                }

            InputView(inputType: .cabinCrew)
                .tabItem {
                    Image(systemName: "paperplane.fill")
                    Text("Cabin Crew")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
