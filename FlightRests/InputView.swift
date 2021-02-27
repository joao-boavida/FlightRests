//
//  InputView.swift
//  FlightRests
//
//  Created by Joao Boavida on 26/02/2021.
//

import SwiftUI

enum InputType {
    case flightCrew, cabinCrew
}

struct InputView: View {

    @State private var beginDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 12, to: Date()) ?? .distantFuture
    @State private var numberOfPilots = 2
    @State private var numberOfRestPeriods = 2

    let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? .distantPast
    let inOneDay = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? .distantFuture

    let inputType: InputType

    var navBarTitle: String {
        switch inputType {
        case .flightCrew: return "Flight Crew"
        case .cabinCrew: return "Cabin Crew"
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Stepper("\(numberOfPilots) Pilots", value: $numberOfPilots, in: 2 ... 3)
                    Stepper("\(numberOfRestPeriods) Rest Periods", value: $numberOfRestPeriods, in: 2 ... 5)
                }

                Section {
                    VStack {
                        DatePicker("Rest starts at", selection: $beginDate, in: oneDayAgo ... inOneDay, displayedComponents: .hourAndMinute)
                            .accessibility(identifier: "beginDatePicker")

                        DatePicker("Rest ends by", selection: $endDate, in: oneDayAgo ... inOneDay, displayedComponents: .hourAndMinute)
                            .accessibility(identifier: "endDatePicker") // debug

                    }
                }

                Section {
                    Button("Calculate Rests") {
                        // Calculate Rests
                    }
                }
                #if DEBUG
                Section(header: Text("DEBUG")) {
                    Text("Rest Begins: \(beginDate.shortFormatDateTime)") // debug
                    Text("Rest Ends: \(endDate.shortFormatDateTime))")
                }
                #endif
            }.navigationBarTitle(navBarTitle)
        }

    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
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
