//
//  RestRequestView.swift
//  FlightRests
//
//  Created by Joao Boavida on 08/03/2021.
//

import SwiftUI

struct RestRequestView: View {
    let request: RestRequest

    var crewDesignator: String {
        switch request.crewFunction {
        case .flightCrew: return "Pilots"
        case .cabinCrew: return "Groups"
        }
    }

    var body: some View {
        HStack {
            Group {
                //Text(request.beginDate.ddMMDate)
                Text(request.beginDate.shortFormatTime)
                    .font(.title2)
                Spacer()
                Text(request.endDate.shortFormatTime)
                    .font(.title2)
            }
            Spacer()
            VStack {
                Text(String(request.numberOfUsers))
                    .font(.title3)
                Text(crewDesignator)
            }
            Spacer()
            VStack {
                Text(String(request.numberOfPeriods))
                    .font(.title3)
                Text("Periods")
            }
            Spacer()
            Image(systemName: "chevron.forward")
        }.padding()
        
        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
    }
}

struct RestRequestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                RestRequestView(request: .exampleFc1)
                RestRequestView(request: .exampleFc2)
            }
        }

    }
}
