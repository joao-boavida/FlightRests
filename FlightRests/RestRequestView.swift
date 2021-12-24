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

    func dateLabel(for date: Date, in timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.dateTimeStyle = .named
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            return "Today"
        } else {
            return date.ddMMDate(in: timeZone)
        }
    }

    private func timeLabel(for date: Date, in timeZone: TimeZone) -> String {
        date.shortFormatTime(in: timeZone).replacingOccurrences(of: " ", with: "\n")
    }

    /// If the locale's time format includes AM/PM the time should be displayed in 2 lines; otherwise 1 line will do with the appropriate scaling. The testing is done by checking for a space character.
    /// - Parameter timeString: the string to be analysed
    /// - Returns: number of lines according to criterium above
    private func timeLineLimit(_ timeString: String) -> Int {
        timeString.contains(" ") ? 2 : 1
    }

    var body: some View {
        NavigationLink( destination: RestPlanView(restPlan: RestCalculator.calculateRests(from: request)).environment(\.timeZone, request.timeZone)) {
            HStack {
                Group {
                    Text(dateLabel(for: request.beginDate, in: request.timeZone))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    VStack {
                        HStack {
                            Text(timeLabel(for: request.beginDate, in: request.timeZone))
                                .lineLimit(timeLineLimit(request.beginDate.shortFormatTime(in: request.timeZone)))
                            Spacer()
                            Text(timeLabel(for: request.endDate, in: request.timeZone))
                                .lineLimit(timeLineLimit(request.endDate.shortFormatTime(in: request.timeZone)))
                        }
                        Text(request.timeZone.abbreviation() ?? "?").font(.callout)
                    }.padding(.horizontal)

                }.multilineTextAlignment(.center)
                .font(.title2)
                .minimumScaleFactor(0.5)

                Spacer()
                VStack {
                    Text(String(request.numberOfPeriods))
                        .font(.title3)
                    Text("Periods")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }.padding()
        }
    }
}

struct RestRequestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                RestRequestView(request: .exampleToday)
                RestRequestView(request: .exampleYesterday)
                RestRequestView(request: .exampleFc1)
                RestRequestView(request: .exampleFc2)
            }
        }
    }
}
