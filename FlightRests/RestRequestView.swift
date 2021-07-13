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

    /// If the locale's time format includes AM/PM the time should be displayed in 2 lines; otherwise 1 line will do with the appropriate scaling. The testing is done by checking for a space character.
    /// - Parameter timeString: the string to be analysed
    /// - Returns: number of lines according to criterium above
    private func timeLineLimit(_ timeString: String) -> Int {
        timeString.contains(" ") ? 2 : 1
    }

    var body: some View {
        HStack {
            Group {
                Text(request.beginDate.ddMMDate)
                    .lineLimit(1)
                Text(request.beginDate.shortFormatTime)
                    .lineLimit(timeLineLimit(request.beginDate.shortFormatTime))
                Spacer()
                Text(request.endDate.shortFormatTime)
                    .lineLimit(timeLineLimit(request.endDate.shortFormatTime))

            }.multilineTextAlignment(.center)
            .font(.title2)
            .minimumScaleFactor(0.5)
            Spacer()
            VStack {
                Text(String(request.numberOfUsers))
                    .font(.title3)
                Text(crewDesignator)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
            VStack {
                Text(String(request.numberOfPeriods))
                    .font(.title3)
                Text("Periods")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
            List {
                RestRequestView(request: .exampleFc1)
                RestRequestView(request: .exampleFc2)
                    .environment(\.locale, Locale(identifier: "en_PT"))
            }
        }
    }
}
