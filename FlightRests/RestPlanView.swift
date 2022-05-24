//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

    var restPlan: [AssignedRestPeriod]

    var titleString: String {
        if restPlan.isEmpty {
            return "Rest Plan"
        } else {
            switch restPlan.first!.crewFunction {

            case .flightCrew:
                return "Flight Crew Rests"
            case .cabinCrew:
                return "Cabin Crew Rests"
            }
        }
    }

    @Environment(\.timeZone) var environmentTimeZone
    @Environment(\.verticalSizeClass) var verticalSizeClass

    let timeColors = [Color.blue, Color.red, Color.green, Color.purple, Color.orange]

    var body: some View {
        if restPlan.isEmpty {
            Text("No Data to Display")
                .font(.title)
                .navigationBarTitle(titleString)
        } else {
            if verticalSizeClass == .compact {
                ScrollView {
                    VStack {
                        // ternary operator added here as a safeguard to prevent crash due to index out of range; the color black should never be used.
                        ForEach(restPlan) { period in
                            RestPeriodView(restPeriod: period, timeColour: period.owner <= timeColors.count ? timeColors[period.owner - 1] : Color.black).environment(\.timeZone, environmentTimeZone)
                        }.padding(.vertical)
                    }.navigationBarTitle(titleString)

                }
            } else {
                VStack {
                    Text(titleString)
                        .font(.largeTitle)
                    Spacer()
                        .frame(maxHeight: 50)
                    // ternary operator added here as a safeguard to prevent crash due to index out of range; the color black should never be used.
                    ForEach(restPlan) { period in
                        RestPeriodView(restPeriod: period, timeColour: period.owner <= timeColors.count ? timeColors[period.owner - 1] : Color.black).environment(\.timeZone, environmentTimeZone)
                    }.padding(.vertical)
                    Spacer()
                        .frame(maxHeight: 50)
                    Text("🛩 🌙 🛩")
                        .font(.largeTitle)
                }

            }
        }

    }
}

struct RestPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
            RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
        }
    }
}
