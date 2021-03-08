//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

    var restPlan: [AssignedRestPeriod]

    @Environment(\.timeZone) var environmentTimeZone

    var body: some View {
        ZStack {
            // Color.accentColor.opacity(0.2)
            VStack {
                if restPlan.isEmpty {
                    Text("No Data to Display")
                        .font(.title)
                } else {
                    ForEach(restPlan) { period in
                        RestPeriodView(restPeriod: period)
                    }.padding(.bottom)
                }
                #if DEBUG
                Text(environmentTimeZone.debugDescription)
                #endif
            }
        }
        .navigationBarTitle("Rest Plan", displayMode: .inline)
    }
}

struct RestPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
        }
    }
}
