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

    /// The date picked by the Rest Begins Date Picker.
    @State private var rawBeginDate = Date().round(precision: 300, rule: .up)

    /// The date picked by the Rest Ends Date Picker
    @State private var rawEndDate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture

    /// The date of the expected landing, for cabin crew, as it is used with the service to calculate the date for the end of the rests
    @State private var rawLandingDate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())?.round(precision: 300, rule: .up) ?? .distantFuture

    /// Selection in the `beforeServiceLabels` array
    @State private var beforeServiceSelection = DefaultValues.beforeServiceSelection

    /// selectable options for before service interval
    let beforeServiceLabels = ["No time", "5min", "10min", "15min", "20min"]

    /// Selection in the `serviceSelection` array
    @State private var serviceSelection = DefaultValues.serviceSelection

    /// Selectable options for service duration
    let serviceLabels = ["No time", "1h00", "1h15", "1h30", "1h45", "2h00", "2h15", "2h30", "2h45", "3h00"]

    /// Number of pilots or groups
    @State private var numberOfUsers = DefaultValues.users

    /// Number of rest periods
    @State private var numberOfRestPeriods = DefaultValues.restPeriods

    /// Selection in the `breakPickerLabels` array
    @State private var minimumBreakSelection = DefaultValues.minimumBreakSelection

    /// Option that, if true, will make the calculator optimise breaks
    @State private var optimiseBreaks = DefaultValues.optimiseBreaks

    /// Selectable durations for breaks
    let breakPickerLabels = ["None", "5 min", "10 min", "15 min", "20 min"]

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

    @State private var versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

    /// A binding to the tabSelection variable on the Tab View host to enable programmatic tab changes, which are triggered as part of the input view refresh.
    @Binding var tabSelection: CrewFunction

    /// A computed variable which builds the rest request from the appropriate data; if the view is being used for pilots, the number of users gets set to the number of users parameter, otherwise it is set to the number of periods as the previous parameter is unused.
    var restRequest: RestRequest {
        RestRequest(beginDate: beginDate, endDate: endDate, numberOfUsers: crewFunction == .flightCrew ? numberOfUsers : numberOfRestPeriods, numberOfPeriods: numberOfRestPeriods, minimumBreakUnits: minimumBreakSelection, crewFunction: crewFunction, timeZone: timeZone, optimiseBreaks: optimiseBreaks)
    }

    /// The navigation bar title, either flight crew or cabin crew.
    var navBarTitle: String {
        switch crewFunction {
        case .flightCrew: return "Flight Crew"
        case .cabinCrew: return "Cabin Crew"
        }
    }

    var calculateButtonFooterString: String {
        switch RestCalculator.validateInputs(from: restRequest) {
        case .valid:
            return ""
        case .negativeInterval:
            switch crewFunction {
            case .flightCrew:
                return "The time at which rest begins must not be later than that at which rest ends."
            case .cabinCrew:
                return "The time at which rest begins must not be later than that at which rest ends and must include time for the selected duration of service."
            }
        case .tooSmallInterval:
            return "There is not enough time in the selected interval to calculate a rest plan. Either start earlier, end later, reduce breaks or reduce the number of rest periods."
        case .unsupportedCombination:
            return "Please change the combination of number of pilots and number of rest periods as the current one is not supported."
        }
    }

    /// Minimum break duration as a time interval, built from the user's selection
    var minimumBreakDuration: TimeInterval {
        Double(300 * minimumBreakSelection)
    }
    var serviceTimeSeconds: Int {
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
        let beforeServiceAdjustment = beforeServiceSelection * 300 // in seconds
        return serviceAdjustment + beforeServiceAdjustment
    }

    /// A closure that resets the input view when called due to idle time
    var resetInputView: (() -> Void) {
        return {
            rawBeginDate = Date().round(precision: 300, rule: .up)
            rawEndDate = Calendar.current.date(byAdding: .hour, value: 3, to: rawBeginDate) ?? .distantFuture
            restPeriodsReadyForAutoUpdate = true
            tabSelection = requestLog.mostRecentFunction()
        }
    }

    /// A closure that resets the user selectable options to their default values
    var resetUserSelections: (() -> Void) {
        return {
            beforeServiceSelection = DefaultValues.beforeServiceSelection
            serviceSelection = DefaultValues.serviceSelection
            numberOfUsers = DefaultValues.users
            numberOfRestPeriods = DefaultValues.restPeriods
            minimumBreakSelection = DefaultValues.minimumBreakSelection
            optimiseBreaks = DefaultValues.optimiseBreaks
        }
    }

    /// A boolean that checks if user options have been changed.
    var areUserOptionsSameAsDefault: Bool {
        beforeServiceSelection == DefaultValues.beforeServiceSelection &&
        serviceSelection == DefaultValues.serviceSelection &&
        numberOfUsers == DefaultValues.users &&
        numberOfRestPeriods == DefaultValues.restPeriods &&
        minimumBreakSelection == DefaultValues.minimumBreakSelection &&
        optimiseBreaks == DefaultValues.optimiseBreaks
    }

    var beginDate: Date {
        DateAdjuster.adjustedBeginDate(rawBeginDate)
    }

    /// The end date value which will be processed by the rest calculator; it handles correction of the appropriate datepicker value as well as consideration of the service time for cabin crew
    var endDate: Date {
        DateAdjuster.adjustedEndDate(beginDate, rawEndDate, rawLandingDate, serviceTimeSeconds, crewFunction)
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

    /// The footer that describes the optimize breaks option when it is selected on
    var breaksSectionFooterString: String {
        if optimiseBreaks {
            return "If possible, breaks will be increased without reducing rest periods."
        } else {
            return ""
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
                        DatePicker("Rest Begins", selection: $rawBeginDate, displayedComponents: [.hourAndMinute])
                            .accessibility(identifier: "beginDatePicker")
                        switch crewFunction {
                        case .flightCrew:
                            DatePicker("Rest Ends", selection: $rawEndDate, displayedComponents: [.hourAndMinute])
                                .accessibility(identifier: "endDatePicker")
                        case .cabinCrew:
                            DatePicker("Landing Time", selection: $rawLandingDate, displayedComponents: [.hourAndMinute])
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
                        if serviceSelection == 0 {
                            Stepper("**\(beforeServiceLabels[beforeServiceSelection])** before Landing", value: $beforeServiceSelection, in: 0 ... beforeServiceLabels.count - 1)
                        } else {
                            Stepper("**\(beforeServiceLabels[beforeServiceSelection])** before Service", value: $beforeServiceSelection, in: 0 ... beforeServiceLabels.count - 1)
                        }
                        Stepper("**\(serviceLabels[serviceSelection])** for Service", value: $serviceSelection, in: 0 ... serviceLabels.count - 1)
                    }
                    Stepper("**\(numberOfRestPeriods)** Rest Periods", value: $numberOfRestPeriods, in: 2 ... 5)
                        .onChange(of: numberOfRestPeriods) { _ in
                            restPeriodsReadyForAutoUpdate = false
                        }
                }
                // Minimum Break and break optimisation
                Section(footer: Text(breaksSectionFooterString).fixedSize(horizontal: false, vertical: true).animation(Animation.default, value: optimiseBreaks)) {
                    Picker("Minimum Break", selection: $minimumBreakSelection) {
                        ForEach(0 ..< breakPickerLabels.count, id: \.self) {
                            Text("\(breakPickerLabels[$0])")
                        }
                    }
                    .accessibility(identifier: "breakDurationPicker")
                    Toggle("Optimise Breaks", isOn: $optimiseBreaks)
                        .accessibilityIdentifier("optimizeBreaksToggle")
                }
                // Calculate button, disabled if the inputs are not valid
                Section(footer: Text(calculateButtonFooterString).animation(.default)) {
                    NavigationButton(destination: RestPlanView(restPlan: computedRestPlan).environment(\.timeZone, timeZone), title: "Calculate Rests") {
                        computedRestPlan = RestCalculator.calculateRests(from: restRequest)
                        requestLog.addRequest(restRequest)
                    }.disabled(RestCalculator.validateInputs(from: restRequest) != .valid)
                    Button("Reset Selections", role: .destructive) {
                        resetInputView()
                        resetUserSelections()
                    }.disabled(areUserOptionsSameAsDefault)

                }

                // Debug Section
                #if DEBUG
                Section(header: Text("Debug")) {
                    Text("versionNumber: \(versionNumber ?? "nil version")")
                }
                #endif
            }.navigationTitle(navBarTitle)
            // Default Detail View
            WelcomeView(viewType: .calculator)

        } // if the app was on the background for more than one day then reset the input view
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if rawBeginDate < inputResetThreshold {
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
        Group {
            InputView(requestLog: RequestLog(), crewFunction: .flightCrew, tabSelection: .constant(.cabinCrew))
            InputView(requestLog: RequestLog(), crewFunction: .flightCrew, tabSelection: .constant(.cabinCrew))
                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
                .previewInterfaceOrientation(.landscapeLeft)

        }
    }
}
