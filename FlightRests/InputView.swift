//
//  InputView.swift
//  FlightRests
//
//  Created by Joao Boavida on 26/02/2021.
//

import SwiftUI

enum CrewFunction: String, Codable {
    case flightCrew, cabinCrew
}

struct InputView: View {

    @Environment(\.timeZone) var environmentTimeZone

    @State private var beginDate = Date().round(precision: 300, rule: .up)
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture

    @State private var numberOfPilots = 2
    @State private var numberOfRestPeriods = 2

    @State private var minimumBreakSelection = 2
    @State private var useUtcTime = false

    let pickerLabels = ["None", "5 min", "10 min", "15 min"]

    let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? .distantPast
    let inOneDay = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? .distantFuture

    let crewFunction: CrewFunction // to choose between flight crew and cabin crew

    var computedRestPlan: [AssignedRestPeriod] {
        RestCalculator.calculateRests(from: RestRequest(beginDate: beginDate, endDate: endDate, numberOfUsers: numberOfPilots, numberOfPeriods: numberOfRestPeriods, minimumBreakUnits: minimumBreakSelection, crewFunction: crewFunction, timeZone: timeZone))
    }

    var restPlanView: some View {
        RestPlanView(restPlan: computedRestPlan).environment(\.timeZone, timeZone)
    }

    var navBarTitle: String {
        switch crewFunction {
        case .flightCrew: return "Flight Crew"
        case .cabinCrew: return "Cabin Crew"
        }
    }

    var minimumBreakDuration: TimeInterval {
        Double(300 * minimumBreakSelection)
    }

    var resetInputDates: (() -> Void) {
        return {
            beginDate = Date().round(precision: 300, rule: .up)
            endDate = Calendar.current.date(byAdding: .hour, value: 3, to: beginDate) ?? .distantFuture
        }
    }

    var correctedEndDate: Date {
        endDate > beginDate ? endDate : Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 24, to: endDate) ?? endDate
    }

    var timeZone: TimeZone {
        useUtcTime ? TimeZone(secondsFromGMT: 0)! : environmentTimeZone
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        HStack {
                            Text("Rest starts at")
                            Spacer()
                            DatePicker("Rest starts at", selection: $beginDate, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accessibility(identifier: "beginDatePicker")
                        }
                        HStack {
                            Text("Rest ends by")
                            Spacer()
                            DatePicker("Rest ends by", selection: $endDate, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accessibility(identifier: "endDatePicker") // debug
                        }
                        Toggle("Use UTC Time", isOn: $useUtcTime)
                    }.environment(\.timeZone, timeZone)
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
                    NavigationButton(destination: restPlanView, title: "Calculate Rests") {
                        // save request here
                        print("save request") // debug
                    }.disabled(computedRestPlan.isEmpty)
                }
                #if DEBUG
                Section(header: Text("DEBUG")) {
                    Text("beginDate: \(beginDate.shortFormatDateTime)") // debug
                    Text("endDate: \(endDate.shortFormatDateTime)")
                    Text("correctedEndDate: \(correctedEndDate.shortFormatDateTime)")
                    Text("timeZone: \(timeZone.debugDescription)")
                }
                #endif
            }.navigationBarTitle(navBarTitle)
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if beginDate < oneDayAgo {
                resetInputDates()
            }
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .previewDevice("iPhone SE (2nd generation)")
    }
}
