//
//  WelcomeView.swift
//  FlightRests
//
//  Created by João Boavida on 21/04/2022.
//

import SwiftUI

struct WelcomeView: View {

    @State private var orientation = UIDevice.current.orientation

    var body: some View {
        VStack {
            Text("Welcome to FlightRests! 🛩")
                .font(.largeTitle)
                .padding()
            VStack {
                Group {
                    Text("Make your selections using the controls on the left;")
                        .padding()
                    Text("Calculation results will be shown here.")
                        .padding()
                }.font(.title3)
                if orientation.isPortrait {
                    VStack {
                        Text("💡 Swipe from the left to reveal the controls 💡")
                            .padding()
                        Text("🔄 Try rotating your iPad to landscape mode for a different experience! 🔄")
                    }.foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            orientation = UIDevice.current.orientation
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .previewDevice("iPad Air (5th generation)")
            .previewInterfaceOrientation(.portrait)
    }
}
