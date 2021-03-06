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
            InputView(crewFunction: .flightCrew)
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Flight Crew")
                }
            InputView(crewFunction: .cabinCrew)
                .tabItem {
                    Image(systemName: "paperplane.fill")
                    Text("Cabin Crew")
                }
            NavigationView {
                VStack {
                    RestRequestView(request: .exampleFc1)
                    RestRequestView(request: .exampleFc2)
                }
            }
                .tabItem {
                    Image(systemName: "clock")
                    Text("Recent Plans")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
