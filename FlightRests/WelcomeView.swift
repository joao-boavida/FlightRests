//
//  WelcomeView.swift
//  FlightRests
//
//  Created by João Boavida on 21/04/2022.
//

import SwiftUI

/// Enum to make the welcome view adapt to the context in which it is shown, whether it is one of the calculators (cabin crew, flight crew) or the recent requests view
enum WelcomeViewType: String, Codable {
    case calculator, recentRequests
}

struct WelcomeView: View {

    /// Describes a simplified screen orientation. It is initialised to the current orientation, then changed only when a change to portrait or landscape is detected in order to hide or show the tip.
    @State private var orientation = UIDevice.current.orientation

    let viewType: WelcomeViewType

    var body: some View {
        VStack {
            Text("Welcome to FlightRests! 🛩")
                .font(.largeTitle)
                .padding()
            VStack {
                switch viewType {
                case .calculator:
                    Group {
                        Text("Make your selections using the controls on the left;")
                            .padding()
                        Text("Calculation results will be shown here.")
                            .padding()
                    }.font(.title3)
                case .recentRequests:
                    Group {
                        Text("Previous rest calculations will be shown on the left.")
                            .padding()
                        Text("Select one and its results will be shown here.")
                            .padding()
                    }.font(.title3)
                }
                if orientation.isPortrait {
                    VStack {
                        Text("💡 Swipe from the left to reveal the controls. 💡")
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
            switch newOrientation {
            case .portrait, .portraitUpsideDown, .landscapeRight, .landscapeLeft:
                orientation = newOrientation
            default: // in all other orientations (including faceUp/Down the layout is not changed, so that change does not get passed into the view.
                return
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView(viewType: .calculator)
                .previewDevice("iPad Air (5th generation)")
            .previewInterfaceOrientation(.portrait)
            WelcomeView(viewType: .recentRequests)
                .previewDevice("iPad Air (5th generation)")
                .previewInterfaceOrientation(.portrait)
        }
    }
}
