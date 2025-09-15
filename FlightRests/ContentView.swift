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

    /// Variable to enable programmatic tab selections; unused now.
    @State private var tabSelection = CrewFunction.cabinCrew

    var body: some View {
        TabView {
            InputView(requestLog: requestLog, crewFunction: .flightCrew, tabSelection: $tabSelection)
                .tabItem {
                    Image(systemName: DefaultValues.flightCrewIcon)
                    Text("Flight Crew")
                }
                .tag(CrewFunction.flightCrew)
            InputView(requestLog: requestLog, crewFunction: .cabinCrew, tabSelection: $tabSelection)
                .tabItem {
                    Image(systemName: DefaultValues.cabinCrewIcon)
                    Text("Cabin Crew")
                }
                .tag(CrewFunction.cabinCrew)
            RecentRequestsView(requestLog: requestLog)
                .tabItem {
                    Image(systemName: DefaultValues.recentsIcon)
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
