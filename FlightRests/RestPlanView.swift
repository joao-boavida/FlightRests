//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

    /// An enum to control the copy of the save button
    enum SavingStatus: String {
        case saving, notSaving
    }

    /// The rest plan to be displayed, which includes a default timeZone
    @State private var displayedRestPlan: RestPlan?

    /// An already calculated rest plan which will be shown in this view; it has priority over the rest request.
    var forcedRestPlan: RestPlan?

    /// A rest request which can be used to calculate a rest plan
    var restRequest: RestRequest?

    /// Whether or not the clear button is shown
    var showClearButton = true

    /// The role in which the view is being used
    var crewFunction: CrewFunction? {
        guard let displayedRestPlan else { return nil }

        if displayedRestPlan.restPeriods.isEmpty {
            return nil
        } else {
            return displayedRestPlan.restPeriods.first!.crewFunction
        }
    }

    /// The view title string
    var titleString: String {
        switch crewFunction {
        case .flightCrew:
            return "Flight Crew Rests"
        case .cabinCrew:
            return "Cabin Crew Rests"
        case nil:
            return "Empty Plan"
        }
    }

    /// The icon to be disolayed below the title
    var crewIcon: Image? {
        switch crewFunction {
        case .flightCrew:
            return Image(systemName: DefaultValues.flightCrewIcon)
        case .cabinCrew:
            return Image(systemName: DefaultValues.cabinCrewIconOption)
        case nil:
            return nil
        }
    }

    /// The TimeZone which is propagated to the RestPeriodView instances
    var computedTimeZone: TimeZone {
        if timeZoneOverride {
            if displayedRestPlan?.defaultTimeZone.secondsFromGMT() == 0 {
                // override the default time zone to local
                return environmentTimeZone
            } else {
                // override the default time zone to UTC
                return TimeZone(abbreviation: "GMT")!
            }
        } else {
            // use the default time zone of the rest plan or UTC if none is specified
            return displayedRestPlan?.defaultTimeZone ?? TimeZone.gmt
        }
    }

    /// A boolean to track the state of the time zone override button presses by the user
    @State private var timeZoneOverride = false

    /// Variables to store the tokens from the observers so that it can later be dismissed
    @State private var refreshToken: NSObjectProtocol?

    @State private var clearAllToken: NSObjectProtocol?

    /// Boolean to detect whether or not the clear button has been tapped; when this occurs the view should force the welcome screen.
    @State private var clearTapped = false

    /// Boolean to control whether the save button is shown on screen if the horiz size class is regular
    @State private var showSaveButton = false

    /// When true the view will force a welcome view of the recent calculations type
    @State private var forceRecentsWelcomeView = false

    /// Saving status which only influences the copy of the save button
    @State private var savingStatus = SavingStatus.notSaving

    @Environment(\.timeZone) var environmentTimeZone
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) var dismiss

    /// database of requests to be used in the RecentRequestsView
    @ObservedObject var requestLog: RequestLog

    /// The colors to be used in rendering the rest periods, in the order they will be used.,
    let timeColors = [Color.blue, Color.green, Color.red, Color.purple, Color.orange]

    /// True if there is no input data; this should not occur in runtime
    var noInputData: Bool {
        forcedRestPlan == nil && displayedRestPlan == nil
    }

    /// The copy of the save button
    var saveButtonCopy: String {
        switch savingStatus {
        case .notSaving: return "Save Results"
        case .saving: return "😀 Saved!"
        }
    }

    func refreshCalculationResults(specificRequest: RestRequest? = nil) {
        if let forcedRestPlan {
            // show previously calculated rest plan
            displayedRestPlan = forcedRestPlan
        } else {
            // in this case check that a rest request exists

            let requestToUse = specificRequest ?? restRequest
            guard let requestToUse else { return }

            // if so calculate a rest plan
            var computedRestPlan = RestPlan()
            computedRestPlan.restPeriods = RestCalculator.calculateRests(from: requestToUse)

            withAnimation {
                displayedRestPlan = computedRestPlan
            }
        }
    }

    /// The empty state that triggers the calculation
    var emptyState: some View {
        ZStack {
            Color(UIColor.systemBackground)
            Text("...")
        }.task {
            refreshCalculationResults()
            // add the request to the request log for future reference
            if let restRequest {
                requestLog.addRequest(restRequest)
            }
        }
    }

    var body: some View {
        if let displayedRestPlan {
            Group {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Text(titleString)
                            .font(.largeTitle)
                            .padding()
                        crewIcon?
                            .scaleEffect(1.5)
                            .padding()
                        Spacer()
                            .frame(maxHeight: 20)
                        // ternary operator added here as a safeguard to prevent crash due to index out of range; the color black should never be used.
                        ForEach(displayedRestPlan.restPeriods) { period in
                            RestPeriodView(restPeriod: period, timeColour: period.owner <= timeColors.count ? timeColors[period.owner - 1] : Color.black)
                                .environment(\.timeZone, computedTimeZone)
                        }.padding(.vertical)
                        Text("🛩 🌙 🛩")
                            .font(.largeTitle)
                            .padding()
                        if horizontalSizeClass == .regular {
                            if showSaveButton {
                                Button(saveButtonCopy) {
                                    Task {
                                        if let restRequest {
                                            savingStatus = .saving
                                            requestLog.addRequest(restRequest)
                                            // if possible add a small delay so the user notices save was tapped
                                            try? await Task.sleep(nanoseconds: 500_000_000)
                                            withAnimation {
                                                showSaveButton = false
                                            }
                                            savingStatus = .notSaving
                                        }
                                    }
                                }.font(.title2)
                            }
                            if showClearButton {
                                Button("Clear", role: .destructive) {
                                    withAnimation {
                                        dismiss()
                                    }
                                }.font(.title3)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .onChange(of: restRequest) { newValue in
                guard let newValue else { return }
                if newValue.updateKey != restRequest?.updateKey {
                    refreshCalculationResults(specificRequest: newValue)
                    withAnimation {
                        showSaveButton = true
                    }
                }
            }
           .toolbar {
               Button {
                   withAnimation(.spring()) {
                       timeZoneOverride.toggle()
                   }
               } label: {
                   Image(systemName: "clock.arrow.2.circlepath")
               }
           }
        } else {
            emptyState
        }
    }
}

struct RestPlanView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                RestPlanView(forcedRestPlan: RestPlan.exampleEmpty, requestLog: RequestLog(emptyLog: true))
                RestPlanView(forcedRestPlan: RestPlan.exampleEmpty, requestLog: RequestLog(emptyLog: true))
            }
            NavigationView {
                RestPlanView(forcedRestPlan: RestPlan.example1, requestLog: RequestLog(emptyLog: true))
                RestPlanView(forcedRestPlan: RestPlan.example1, requestLog: RequestLog(emptyLog: true))
            }
            NavigationView {
                RestPlanView(forcedRestPlan: RestPlan.example2, requestLog: RequestLog(emptyLog: true))
                RestPlanView(forcedRestPlan: RestPlan.example2, requestLog: RequestLog(emptyLog: true))
            }

        }
    }
}
