//
//  RestPlanView.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import SwiftUI

struct RestPlanView: View {

    var restPlan: [AssignedRestPeriod]

    var body: some View {
        VStack {
            if restPlan.isEmpty {
                Text("No Data to Display")
                    .font(.title)
            } else {
                ForEach(restPlan) { period in
                    RestPeriodView(restPeriod: period)
                }.padding(.bottom)
            }
        }
        .navigationBarTitle("Rest Plan", displayMode: .inline)

    }
}

struct RestPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestPlanView(restPlan: [])
        }
    }
}
