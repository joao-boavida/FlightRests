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

    @State private var beginDate = Date().round(precision: 300, rule: .up)
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 12, to: Date())?.round(precision: 300, rule: .down) ?? .distantFuture
    @State private var numberOfPilots = 2
    @State private var numberOfRestPeriods = 2

    @State private var minimumBreakSelection = 2

    let pickerLabels = ["None", "5 min", "10 min", "15 min"]

    let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? .distantPast
    let inOneDay = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? .distantFuture

    let inputType: InputType

    var computedRestPlan: [AssignedRestPeriod] {
        RestCalculator.calculateRests(from: RestRequest(beginDate: beginDate, endDate: endDate, numberOfUsers: numberOfPilots, numberOfPeriods: numberOfRestPeriods, minimumBreakUnits: minimumBreakSelection))
    }

    var navBarTitle: String {
        switch inputType {
        case .flightCrew: return "Flight Crew"
        case .cabinCrew: return "Cabin Crew"
        }
    }

    var minimumBreakDuration: TimeInterval {
        Double(300 * minimumBreakSelection)
    }

    var body: some View {
        NavigationView {
            Form {

                Section {
                    VStack {
                        HStack {
                            Text("Rest starts at")
                            Spacer()
                            DatePicker("Rest starts at", selection: $beginDate, in: oneDayAgo ... inOneDay, displayedComponents: .hourAndMinute)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accessibility(identifier: "beginDatePicker")
                        }
                        HStack {
                            Text("Rest ends by")
                            Spacer()
                            DatePicker("Rest ends by", selection: $endDate, in: oneDayAgo ... inOneDay, displayedComponents: .hourAndMinute)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accessibility(identifier: "endDatePicker") // debug
                        }
                    }
                }

                Section {
                    Stepper("\(numberOfPilots) Pilots", value: $numberOfPilots, in: 2 ... 3)
                    Stepper("\(numberOfRestPeriods) Rest Periods", value: $numberOfRestPeriods, in: 2 ... 5)
                }

                Section {
                    Picker("Minimum Break", selection: $minimumBreakSelection) {
                        ForEach(0 ..< pickerLabels.count) {
                            Text("\(pickerLabels[$0])")
                        }
                    }
                    .accessibility(identifier: "breakDurationPicker")
                }

                Section {
                    NavigationLink(
                        destination: RestPlanView(restPlan: computedRestPlan),
                        label: {
                            Text("Calculate Rests")
                                .foregroundColor(.accentColor)
                                .font(.headline)
                        })
                }
                #if DEBUG
                Section(header: Text("DEBUG")) {
                    Text("Rest Begins: \(beginDate.shortFormatDateTime)") // debug
                    Text("Rest Ends: \(endDate.shortFormatDateTime)")
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
        .previewDevice("iPhone SE (2nd generation)")
    }
}
