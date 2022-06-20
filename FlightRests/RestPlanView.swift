//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

    /// The rest plan to be displayed
    var restPlan: [AssignedRestPeriod]

    /// Whether or not the clear button is shown
    var showClearButton = true

    /// The role in which the view is being used
    var crewFunction: CrewFunction? {
        if restPlan.isEmpty {
            return nil
        } else {
            return restPlan.first!.crewFunction
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

    /// Variable to store the token from the observer so that it can later be dismissed
    @State private var refreshToken: NSObjectProtocol?

    @State private var clearAllToken: NSObjectProtocol?

    /// Boolean to detect whether or not the clear button has been pushed; when this occurs the view should force the welcome screen.
    @State private var clearPushed = false

    /// When true the view will force a welcome view of the recent calculations type
    @State private var forceRecentsWelcomeView = false

    @Environment(\.timeZone) var environmentTimeZone
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) var dismiss

    /// The colors to be used in rendering the rest periods, in the order they will be used.,
    let timeColors = [Color.blue, Color.green, Color.red, Color.purple, Color.orange]

    var body: some View {
        Group {
            if forceRecentsWelcomeView {
                WelcomeView(viewType: .recentRequests)
            } else {
                if restPlan.isEmpty || clearPushed {
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
                            ForEach(restPlan) { period in
                                RestPeriodView(restPeriod: period, timeColour: period.owner <= timeColors.count ? timeColors[period.owner - 1] : Color.black).environment(\.timeZone, environmentTimeZone)
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

        }
    }
}

struct RestPlanView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                RestPlanView(restPlan: [])
                RestPlanView(restPlan: [])
            }
            NavigationView {
                RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
                RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
            }
            NavigationView {
                RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
                RestPlanView(restPlan: [.example1, .example2])
            }

        }
    }
}
