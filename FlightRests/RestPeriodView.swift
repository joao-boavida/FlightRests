//
//  RestPeriodView.swift
//  FlightRests
//
//  Created by Joao Boavida on 26/02/2021.
//

import SwiftUI

struct RestPeriodView: View {

    @Environment(\.timeZone) var environmentTimeZone

    let restPeriod: AssignedRestPeriod

    var timeZoneAbb: String {
        environmentTimeZone.abbreviation() ?? ""
    }

    var body: some View {
        HStack {
            VStack {
                Text(restPeriod.period.start.shortFormatTime)
                    .font(.title)
                    .foregroundColor(.accentColor)
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
                Text(restPeriod.period.end.shortFormatTime)
                    .font(.title)
                    .foregroundColor(.accentColor)
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
    }
}

struct RestPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                RestPeriodView(restPeriod: .example1)
                RestPeriodView(restPeriod: .example2)
            }

        }.colorScheme(.light)

    }
}
