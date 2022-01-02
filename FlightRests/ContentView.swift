//
//  ContentView.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import SwiftUI

struct ContentView: View {

    /// Initialisation of the requests database
    @StateObject var requestLog = RequestLog()

    var body: some View {
        TabView {
            InputView(requestLog: requestLog, crewFunction: .flightCrew)
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Flight Crew")
                }
            InputView(requestLog: requestLog, crewFunction: .cabinCrew)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Cabin Crew")
                }
            RecentRequestsView(requestLog: requestLog)
                .tabItem {
                    Image(systemName: "clock")
                    Text("Recent")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
