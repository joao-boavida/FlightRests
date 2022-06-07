//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

    /* View not updating properly when calculate button is pressed again on an ipad landscape because the onAppear method is not triggered; consider turning restPlan into an observed object, but that may not work either. ?? */

    var restPlan: [AssignedRestPeriod]

    var role: CrewFunction? {
        if displayedRestPlan.isEmpty {
            return nil
        } else {
            return displayedRestPlan.first!.crewFunction
        }
    }

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

    @State private var displayedRestPlan: [AssignedRestPeriod] = []

    @Environment(\.timeZone) var environmentTimeZone
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) var dismiss

    let timeColors = [Color.blue, Color.red, Color.green, Color.purple, Color.orange]

    var body: some View {
        Group {
            if displayedRestPlan.isEmpty {
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
                        ForEach(displayedRestPlan) { period in
                            RestPeriodView(restPeriod: period, timeColour: period.owner <= timeColors.count ? timeColors[period.owner - 1] : Color.black).environment(\.timeZone, environmentTimeZone)
                        }.padding(.vertical)
                        Text("🛩 🌙 🛩")
                            .font(.largeTitle)
                            .padding()
                        Button("Clear", role: .destructive) {
                            displayedRestPlan.removeAll()
                            dismiss()
                        }.font(.title)
                            .padding()
                    }
                }
            }
        }.onAppear {
            print("onappear triggered on restplanview")
            displayedRestPlan = restPlan
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
