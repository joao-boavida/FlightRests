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

    /// database of requests to be used in the RecentRequestsView
    @ObservedObject var requestLog: RequestLog

    @State private var beginDate = Date().round(precision: 300, rule: .up)
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture
    @State private var landingDate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture

    @State private var serviceSelection = 3

    @State private var numberOfUsers = 2
    @State private var numberOfRestPeriods = 2

    @State private var minimumBreakSelection = 2
    @State private var useLocalTime = false

    @State private var currentDate = Date()

    @State private var computedRestPlan: [AssignedRestPeriod] = []

    let breakPickerLabels = ["None", "5 min", "10 min", "15 min"]
    let servicePickerLabels = ["No Time", "1h00", "1h15", "1h30", "1h45", "2h00", "2h15", "2h30"]

    let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? .distantPast
    let inOneDay = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? .distantFuture

    let crewFunction: CrewFunction // to choose between flight crew and cabin crew

    var restRequest: RestRequest {
        RestRequest(beginDate: beginDate, endDate: correctedEndDate, numberOfUsers: numberOfUsers, numberOfPeriods: numberOfRestPeriods, minimumBreakUnits: minimumBreakSelection, crewFunction: crewFunction, timeZone: timeZone)
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
        switch crewFunction {
        case .flightCrew:
            return endDate > beginDate ? endDate : Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 24, to: endDate) ?? endDate
        case .cabinCrew:
            var correctedDate = landingDate > beginDate ? landingDate : Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 24, to: landingDate) ?? landingDate
            let serviceAdjustment = servicePickerLabels[serviceSelection].components(separatedBy: "h") // hours and minutes in strings
                .map {Int($0) ?? 0} // strings should be numbers only so this conversion should be straightforward
                .enumerated() // tuples with the indexes
                .reduce(0) { (accumulate, current) in // converted to seconds and added
                    if current.0 == 0 {
                        return current.1 * 3600
                    } else {
                        return accumulate + current.1 * 60
                    }
                }
            correctedDate.addTimeInterval(Double(-1 * serviceAdjustment))
            return correctedDate
        }
    }

    var timeZone: TimeZone {
        useLocalTime ? environmentTimeZone : TimeZone(secondsFromGMT: 0)!
    }

    let timer = Timer.TimerPublisher(interval: 0.5, runLoop: .main, mode: .common).autoconnect()

    var currentTimeString: String {
        if timeZone.secondsFromGMT() == 0 {
            // utc time, fixed format and no label
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = timeZone
            dateFormatter.locale = .autoupdatingCurrent
            dateFormatter.dateFormat = "HH:mm:ss"
            return dateFormatter.string(from: currentDate)
        } else {
            let longTime = currentDate.longFormatTime(in: timeZone)
            return longTime.replacingOccurrences(of: "GMT", with: "UTC")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // Current time and Local Time Option
                Section {
                    VStack {
                        Text(currentTimeString)
                            .font(.largeTitle)
                            .padding()
                        Toggle("Use Local Time", isOn: $useLocalTime)
                    }
                }
                // Beginning and End Times
                Section {
                    VStack {
                        DatePicker("Rest Begins", selection: $beginDate, displayedComponents: [.hourAndMinute])
                            .accessibility(identifier: "beginDatePicker")
                        switch crewFunction {
                        case .flightCrew:
                            DatePicker("Rest Ends", selection: $endDate, displayedComponents: [.hourAndMinute])
                                .accessibility(identifier: "endDatePicker")
                        case .cabinCrew:
                            DatePicker("Landing Time", selection: $landingDate, displayedComponents: [.hourAndMinute])
                                .accessibility(identifier: "landingTimePicker")
                        }
                        #if DEBUG
                        Text(correctedEndDate.debugDescription)
                        #endif
                    }.environment(\.timeZone, timeZone)

                }

                // Number of users and Groups
                Section {
                    Stepper("**\(numberOfRestPeriods)** Rest Periods", value: $numberOfRestPeriods, in: 2 ... 5)
                    switch crewFunction {
                    case .flightCrew:
                        Stepper("**\(numberOfUsers)** Pilots", value: $numberOfUsers, in: 2 ... 3)
                    case .cabinCrew:
                        Stepper("**\(numberOfUsers)** Groups", value: $numberOfUsers, in: 2 ... 3)
                        Stepper("**\(servicePickerLabels[serviceSelection])** for Service", value: $serviceSelection, in: 0 ... servicePickerLabels.count - 1)
                    }
                }
                // Minimum Break
                Section {
                    Picker("Minimum Break", selection: $minimumBreakSelection) {
                        ForEach(0 ..< breakPickerLabels.count) {
                            Text("\(breakPickerLabels[$0])")
                        }
                    }
                    .accessibility(identifier: "breakDurationPicker")
                }

                Section {
                    NavigationButton(destination: RestPlanView(restPlan: computedRestPlan).environment(\.timeZone, timeZone), title: "Calculate Rests") {
                        computedRestPlan = RestCalculator.calculateRests(from: restRequest)
                        requestLog.addRequest(restRequest)
                    }.disabled(!RestCalculator.validateInputs(from: restRequest))
                }
            }.navigationBarTitle(navBarTitle)
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if beginDate < oneDayAgo {
                resetInputDates()
            }
        }
        .onReceive(timer) { input in
            currentDate = input
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(requestLog: RequestLog(), crewFunction: .cabinCrew)
        .previewDevice("iPhone SE (2nd generation)")
    }
}
