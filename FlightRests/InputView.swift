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

    @State private var numberOfPilots = 2
    @State private var numberOfRestPeriods = 2

    @State private var minimumBreakSelection = 2
    @State private var useLocalTime = false

    @State private var currentDate = Date()

    @State private var computedRestPlan: [AssignedRestPeriod] = []

    let pickerLabels = ["None", "5 min", "10 min", "15 min"]

    let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? .distantPast
    let inOneDay = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? .distantFuture

    let crewFunction: CrewFunction // to choose between flight crew and cabin crew

    var restRequest: RestRequest {
        RestRequest(beginDate: beginDate, endDate: correctedEndDate, numberOfUsers: numberOfPilots, numberOfPeriods: numberOfRestPeriods, minimumBreakUnits: minimumBreakSelection, crewFunction: crewFunction, timeZone: timeZone)
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
                Section {
                    VStack {
                        Text(currentTimeString)
                            .font(.largeTitle)
                            .padding()
                        Toggle("Use Local Time", isOn: $useLocalTime)
                    }
                }
                Section {
                    VStack {
                        DatePicker("Rest starts at", selection: $beginDate, displayedComponents: [.hourAndMinute])
                            .accessibility(identifier: "beginDatePicker")
                        DatePicker("Rest ends by", selection: $endDate, displayedComponents: [.hourAndMinute])
                            .accessibility(identifier: "endDatePicker")
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
        ContentView()
        .previewDevice("iPhone SE (2nd generation)")
    }
}
