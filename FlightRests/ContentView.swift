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

    @State private var tabSelection = CrewFunction.flightCrew

    var body: some View {
        TabView(selection: $tabSelection) {
            InputView(requestLog: requestLog, crewFunction: .flightCrew, tabSelection: $tabSelection)
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Flight Crew")
                }
                .tag(CrewFunction.flightCrew)
            InputView(requestLog: requestLog, crewFunction: .cabinCrew, tabSelection: $tabSelection)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Cabin Crew")
                }
                .tag(CrewFunction.cabinCrew)
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
