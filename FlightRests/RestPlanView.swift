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

    /// The role in which the view is being used
    var role: CrewFunction? {
        if restPlan.isEmpty {
            return nil
        } else {
            return restPlan.first!.crewFunction
        }
    }

    /// The view title string
    var titleString: String {
        switch role {
        case .flightCrew:
            return "Flight Crew Rests"
        case .cabinCrew:
            return "Cabin Crew Rests"
        case nil:
            return "Empty Plan"
        }
    }

    /// The icon to be disolayed below the title
    var icon: Image? {
        switch role {
        case .flightCrew:
            return Image(systemName: DefaultValues.flightCrewIcon)
        case .cabinCrew:
            return Image(systemName: DefaultValues.cabinCrewIcon)
        case nil:
            return nil
        }
    }

    /// Variable to store the token from the observer so that it can later be dismissed
    @State private var observerToken: NSObjectProtocol?

    /// Boolean to detect whether or not the clear button has been pushed; when this occurs the view should force the welcome screen.
    @State private var clearPushed = false

    @Environment(\.timeZone) var environmentTimeZone
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) var dismiss

    let timeColors = [Color.blue, Color.green, Color.red, Color.purple, Color.orange]

    var body: some View {
        Group {
            if restPlan.isEmpty || clearPushed {
                WelcomeView(viewType: .calculator)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Text(titleString)
                            .font(.largeTitle)
                            .padding()
                        icon?
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
                        if horizontalSizeClass == .regular {
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
        }.onAppear {
            // adds an observer so that when this notification is received the view should prepare for updating
            observerToken = NotificationManager.observeRefreshNotification {
                clearPushed = false
            }
        }
        .onDisappear {
            // removes the observer when the view is dismissed
            guard let observerToken = observerToken else { return }
            NotificationManager.removeRefreshObserver(token: observerToken)
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
