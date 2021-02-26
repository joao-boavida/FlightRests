//
//  InputView.swift
//  FlightRests
//
//  Created by Joao Boavida on 26/02/2021.
//

import SwiftUI

enum InputType {
    case flightCrew, cabinCrew
}

struct InputView: View {

    let inputType: InputType

    var navBarTitle: String {
        switch inputType {
        case .flightCrew: return "Flight Crew"
        case .cabinCrew: return "Cabin Crew"
        }
    }

    var body: some View {
        NavigationView {
            Text("Hello World")
                .navigationBarTitle(navBarTitle)
        }

    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            InputView(inputType: .flightCrew)
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Flight Crew")
                }

            InputView(inputType: .cabinCrew)
                .tabItem {
                    Image(systemName: "paperplane.fill")
                    Text("Cabin Crew")
                }
        }
    }
}
