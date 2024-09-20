//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

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

    /// Boolean to detect whether or not the clear button has been pushed; when this occurs the view should force the welcome screen.
    @State private var clearPushed = false

    /// When true the view will force a welcome view of the recent calculations type
    @State private var forceRecentsWelcomeView = false

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

    /// The empty state that triggers the calculation
    var emptyState: some View {
        ZStack {
            Color(UIColor.systemBackground)
            Text("...")
        }.task {
            if let forcedRestPlan {
                // show previously calculated rest plan
                displayedRestPlan = forcedRestPlan
            } else {
                // in this case check that a rest request exists
                guard let restRequest else { return }

                // if so calculate a rest plan
                var computedRestPlan = RestPlan()
                computedRestPlan.restPeriods = RestCalculator.calculateRests(from: restRequest)

                // inform the restplanview, if visible, that it should refresh, to prevent bugs on largescreen ipads
                NotificationManager.postRefreshNotification()

                // add the request to the request log for future reference
                requestLog.addRequest(restRequest)

                withAnimation {
                    displayedRestPlan = computedRestPlan
                }
            }
        }
    }

    var body: some View {
        if let displayedRestPlan {
            Group {
                if forceRecentsWelcomeView {
                    WelcomeView(viewType: .recentRequests)
                } else {
                    if displayedRestPlan.restPeriods.isEmpty || clearPushed {
                        if let crewFunction = crewFunction {
                            WelcomeView(crewFunction: crewFunction)
                        } else {
                            WelcomeView(viewType: .unknown)
                        }
                    } else {
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
                                if horizontalSizeClass == .regular && showClearButton {
                                    Button("Clear Results", role: .destructive) {
                                        dismiss()
                                        // if due to the strange behaviour on ipad landscape the view does not dismiss this boolean will force the welcome view to be shown
                                        withAnimation {
                                            clearPushed = true
                                        }
                                    }.font(.title2)
                                        .padding()
                                }

                            }
                        }
                    }
                }
            }.onAppear {
                // adds an observer so that when this notification is received the view should prepare for updating
                refreshToken = NotificationManager.observeRefreshNotification {
                    clearPushed = false
                    forceRecentsWelcomeView = false
                }
                // adds an observer to detect the pressing of the clear all button, which will trigger a welcomeview in that case.
                clearAllToken = NotificationManager.observeClearAllNotification {
                    withAnimation {
                        forceRecentsWelcomeView = true
                    }
                }
            }
            .onDisappear {
                // removes the observers when the view is dismissed
                if let refreshToken = refreshToken {
                    NotificationManager.removeRefreshObserver(token: refreshToken)
                }
                if let clearAllToken = clearAllToken {
                    NotificationManager.removeClearAllObserver(token: clearAllToken)
                }

            }.toolbar {
                if !clearPushed {
                    Button {
                        withAnimation(.spring()) {
                            timeZoneOverride.toggle()
                        }
                    } label: {
                        Image(systemName: "clock.arrow.2.circlepath")
                    }
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
