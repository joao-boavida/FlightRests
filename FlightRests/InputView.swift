//
//  InputView.swift
//  FlightRests
//
//  Created by Joao Boavida on 26/02/2021.
//

import SwiftUI

/// An enum to control whether the input view is in Flight Crew or Cabin Crew mode.
enum CrewFunction: String, Codable {
    case flightCrew, cabinCrew
}

struct InputView: View {

    /// The time zone in which the system is currently in
    @Environment(\.timeZone) var environmentTimeZone

    /// database of requests to be used in the RecentRequestsView
    @ObservedObject var requestLog: RequestLog

    /// A variable controlling whether the screen is in cabin crew or flight crew mode
    let crewFunction: CrewFunction // to choose between flight crew and cabin crew modes

    @State private var firstAppear = true

    /// The date at which rests should begin
    @State private var beginDate = Date().round(precision: 300, rule: .up)

    /// The date by which rests should end for flight crew
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture

    /// The date of the expected landing, for cabin crew, as it is used with the service to calculate the date for the end of the rests
    @State private var landingDate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture

    /// Selection in the `serviceSelection` array
    @State private var serviceSelection = 4

    /// Selectable options for service duration
    let serviceLabels = ["No Time", "1h00", "1h15", "1h30", "1h45", "2h00", "2h15", "2h30", "2h45", "3h00"]

    /// Number of pilots or groups
    @State private var numberOfUsers = 2

    /// Number of rest periods
    @State private var numberOfRestPeriods = 2

    /// Selection in the `breakPickerLabels` array
    @State private var minimumBreakSelection = 2

    /// Selectable durations for breaks
    let breakPickerLabels = ["None", "5 min", "10 min", "15 min"]

    /// Option to use local time; when false, UTC is used
    @State private var useLocalTime = false

    /// A cached value of the present date, used for the on screen clock
    @State private var currentDate = Date()

    /// Used to correct the outputs from the datepickers if a long time has passed since the app was opened
    let inputResetThreshold = Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? .distantPast

    /// One day after the present date, used to correct the outputs from the datepickers
    let inOneDay = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? .distantFuture

    /// The computed rest plan which will be sent to the viewer, as an array of assigned rest periods
    @State private var computedRestPlan: [AssignedRestPeriod] = []

    /// The number of rest periods will be updated automatically only the first time the number of users is increased before touching the number of rest periods; this variable controls that behaviour.
    @State private var restPeriodsReadyForAutoUpdate = true

    /// A binding to the tabSelection variable on the Tab View host to enable programmatic tab changes, which are triggered as part of the input view refresh.
    @Binding var tabSelection: CrewFunction

    /// A computed variable which builds the rest request from the appropriate data; if the view is being used for pilots, the number of users gets set to the number of users parameter, otherwise it is set to the number of periods as the previous parameter is unused.
    var restRequest: RestRequest {
        RestRequest(beginDate: beginDate, endDate: correctedEndDate, numberOfUsers: crewFunction == .flightCrew ? numberOfUsers : numberOfRestPeriods, numberOfPeriods: numberOfRestPeriods, minimumBreakUnits: minimumBreakSelection, crewFunction: crewFunction, timeZone: timeZone)
    }

    /// The navigation bar title, either flight crew or cabin crew.
    var navBarTitle: String {
        switch crewFunction {
        case .flightCrew: return "Flight Crew"
        case .cabinCrew: return "Cabin Crew"
        }
    }

    /// Minimum break duration as a time interval, built from the user's selection
    var minimumBreakDuration: TimeInterval {
        Double(300 * minimumBreakSelection)
    }

    /// A closure that resets the input view when called due to idle time
    var resetInputView: (() -> Void) {
        return {
            beginDate = Date().round(precision: 300, rule: .up)
            endDate = Calendar.current.date(byAdding: .hour, value: 3, to: beginDate) ?? .distantFuture
            restPeriodsReadyForAutoUpdate = true
            tabSelection = requestLog.mostRecentFunction()
        }
    }

    /// The end date value which will be processed by the rest calculator; it handles correction of the appropriate datepicker value as well as consideration of the service time for cabin crew
    var correctedEndDate: Date {
        switch crewFunction {
        case .flightCrew:
            return endDate > beginDate ? endDate : Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 24, to: endDate) ?? endDate
        case .cabinCrew:
            var correctedDate = landingDate > beginDate ? landingDate : Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 24, to: landingDate) ?? landingDate
            let serviceAdjustment = serviceLabels[serviceSelection].components(separatedBy: "h") // hours and minutes in strings
                .map {Int($0) ?? 0} // strings should be numbers only so this conversion should be straightforward
                .enumerated() // tuples with the indexes
                .reduce(0) { (accumulate, current) in // converted to seconds and added
                    if current.0 == 0 {
                        return current.1 * 3600 // hours
                    } else {
                        return accumulate + current.1 * 60 // minutes
                    }
                }
            correctedDate.addTimeInterval(Double(-1 * serviceAdjustment)) // the adjustment must be negative as the end of the rests is before the beginning of the service
            return correctedDate
        }
    }

    /// the timezone to be used, which will be either UTC or the environment time zone according to user selection
    var timeZone: TimeZone {
        useLocalTime ? environmentTimeZone : TimeZone(secondsFromGMT: 0)!
    }

    /// The timer used to update the running clock in the main interface
    let timer = Timer.TimerPublisher(interval: 0.5, runLoop: .main, mode: .common).autoconnect()

    /// The string which will be displayed witht the current time, formatted according to the user's selected timezone preferences
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
                    }.environment(\.timeZone, timeZone)

                }

                // Number of users and Groups
                Section {
                    switch crewFunction {
                    case .flightCrew:
                        Stepper("**\(numberOfUsers)** Pilots", value: $numberOfUsers, in: 2 ... 3)
                            .onChange(of: numberOfUsers) { _ in
                                if restPeriodsReadyForAutoUpdate {
                                    if numberOfUsers == 3 && numberOfRestPeriods == 2 {
                                        numberOfRestPeriods = 3
                                        restPeriodsReadyForAutoUpdate = false
                                    }
                                }
                            }
                    case .cabinCrew:
                        Stepper("**\(serviceLabels[serviceSelection])** for Service", value: $serviceSelection, in: 0 ... serviceLabels.count - 1)
                    }
                    Stepper("**\(numberOfRestPeriods)** Rest Periods", value: $numberOfRestPeriods, in: 2 ... 5)
                        .onChange(of: numberOfRestPeriods) { _ in
                            restPeriodsReadyForAutoUpdate = false
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
                // Calculate button, disabled if the inputs are not valid
                Section {
                    NavigationButton(destination: RestPlanView(restPlan: computedRestPlan).environment(\.timeZone, timeZone), title: "Calculate Rests") {
                        computedRestPlan = RestCalculator.calculateRests(from: restRequest)
                        requestLog.addRequest(restRequest)
                    }.disabled(!RestCalculator.validateInputs(from: restRequest))
                }
            }.navigationBarTitle(navBarTitle)
        } // if the app was on the background for more than one day then reset the input view
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if beginDate < inputResetThreshold {
                resetInputView()
            }
        } // updating the on screen clock
        .onReceive(timer) { input in
            currentDate = input
        }
        .onAppear {
            if firstAppear {
                tabSelection = requestLog.mostRecentFunction()
                firstAppear = false
            }
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(requestLog: RequestLog(), crewFunction: .flightCrew, tabSelection: .constant(.flightCrew))
        .previewDevice("iPhone SE (2nd generation)")
    }
}
