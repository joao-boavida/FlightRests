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
        ScrollView {
            VStack {
                if restPlan.isEmpty {
                    Text("No Data to Display")
                        .font(.title)
                } else {
                    ForEach(restPlan) { period in
                        RestPeriodView(restPeriod: period).environment(\.timeZone, environmentTimeZone)
                    }.padding(.vertical)
                }
                Spacer()
            }
        }
        .navigationBarTitle("Rest Plan")
    }
}

struct RestPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestPlanView(restPlan: [.example1, .example2, .example1, .example2])
        }
    }
}
