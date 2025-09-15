//
//  RestRequestView.swift
//  FlightRests
//
//  Created by Joao Boavida on 08/03/2021.
//

import SwiftUI

struct RestRequestView: View {

    /// The request to be displayed
    let request: RestRequest

    /// Function to generate the label of the date relative to the present day
    /// - Parameters:
    ///   - date: the date to be used
    ///   - timeZone: timezone in use
    /// - Returns: The formatted date label, as a string
    func dateLabel(for date: Date, in timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.dateTimeStyle = .named
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            return "Today"
        } else {
            return date.ddMMDate(in: timeZone)
        }
    }

    /// Function to generate the time to be used
    /// - Parameters:
    ///   - date: the date to which the time refers
    ///   - timeZone: the time zone in use
    /// - Returns: A string with the time at which rest begins or ends
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
        NavigationLink(destination: RestPlanView(restRequest: request, showClearButton: false, requestLog: RequestLog(emptyLog: true))) {
            HStack {
                Group {
                    Text(dateLabel(for: request.creationDate, in: TimeZone.autoupdatingCurrent))
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
                        Text(request.timeZone.abbreviation()?.replacingOccurrences(of: "GMT", with: "UTC") ?? "?").font(.callout)
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
