//
//  RestPeriodView.swift
//  FlightRests
//
//  Created by Joao Boavida on 26/02/2021.
//

import SwiftUI

struct RestPeriodView: View {

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.timeZone) var environmentTimeZone

    /// The rest period to be displayed
    let restPeriod: AssignedRestPeriod

    /// The colour to be used in the times
    let timeColour: Color

    /// The time zone abbreviation, obtained from the environment
    var timeZoneAbb: String {
        let abbreviation = environmentTimeZone.abbreviation() ?? ""
        return abbreviation.replacingOccurrences(of: "GMT", with: "UTC")
    }

    var body: some View {
        HStack {
            VStack {
                Text(restPeriod.period.start.shortFormatTime(in: environmentTimeZone))
                    .font(.title)
                    .foregroundColor(timeColour)
                Text(timeZoneAbb)
                    .font(.headline)
            }
            Spacer()
            VStack {
                Text(restPeriod.period.duration.HHmm)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack {
                Text(restPeriod.period.end.shortFormatTime(in: environmentTimeZone))
                    .font(.title)
                    .foregroundColor(timeColour)
                Text(timeZoneAbb)
                    .font(.headline)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary, lineWidth: 4)
        )
        .padding(.horizontal)
        .frame(maxWidth: 500)
    }
}

struct RestPeriodView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            VStack {
                RestPeriodView(restPeriod: .example1, timeColour: .blue)
                RestPeriodView(restPeriod: .example2, timeColour: .green)
                Text("Locale: \(Locale.autoupdatingCurrent.debugDescription)").font(.title2)
            }
            VStack {
                RestPeriodView(restPeriod: .example1, timeColour: .blue)
                RestPeriodView(restPeriod: .example2, timeColour: .green)
                Text("Locale: \(Locale.autoupdatingCurrent.debugDescription)").font(.title2)
            }
            .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
