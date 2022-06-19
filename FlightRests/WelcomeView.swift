//
//  WelcomeView.swift
//  FlightRests
//
//  Created by João Boavida on 21/04/2022.
//

import SwiftUI

/// Enum to make the welcome view adapt to the context in which it is shown, whether it is one of the calculators (cabin crew, flight crew) or the recent requests view
enum WelcomeViewType: String, Codable {
    case flightCrew, cabinCrew, recentRequests, unknown
}

struct WelcomeView: View {

    /// Describes a simplified screen orientation. It is initialised to the current orientation, then changed only when a change to portrait or landscape is detected in order to hide or show the tip.
    @State private var orientation = UIDevice.current.orientation
    @Environment(\.verticalSizeClass) var verticalSizeClass

    /// The type of welcome view to be rendered
    let viewType: WelcomeViewType

    /// The app icon, grabbed from the assets
    let appIcon = Image("icon-inApp")

    /// Custom initialiser to initiate this view from a crew function
    /// - Parameter crewFunction: the crew function for which this view will be initialised
    init(crewFunction: CrewFunction) {
        switch crewFunction {
        case .flightCrew:
            self.viewType = .flightCrew
        case .cabinCrew:
            self.viewType = .cabinCrew
        }
    }

    /// Memberwise initialiser
    /// - Parameter viewType: the welcome view type to be rendered
    init(viewType: WelcomeViewType) {
        self.viewType = viewType
    }

    var body: some View {
        VStack {
            // the app icon is only shown if there is space to spare
            if verticalSizeClass == .regular {
                HStack {
                    Spacer(minLength: 20)
                    appIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()
                        .frame(maxHeight: 300)
                    Spacer(minLength: 20)
                }
            }
            if viewType == .recentRequests {
                Text("Recent Rest Plans")
                    .font(.largeTitle)
                    .padding()
            } else {
                Text("Welcome to FlightRests!")
                    .font(.largeTitle)
                    .padding()
            }
            switch viewType {
            case .flightCrew:
                HStack {
                    Image(systemName: DefaultValues.flightCrewIcon)
                        .scaleEffect(1.5)
                    Text("Flight Crew").fontWeight(.bold).padding()
                    Image(systemName: DefaultValues.flightCrewIcon)
                        .scaleEffect(1.5)
                }.font(.title)
                .padding()
            case .cabinCrew:
                HStack {
                    Image(systemName: DefaultValues.cabinCrewIconOption)
                        .scaleEffect(1.2)
                    Text("Cabin Crew").fontWeight(.bold).padding()
                    Image(systemName: DefaultValues.cabinCrewIconOption)
                        .scaleEffect(1.2)
                }.font(.title)

                .padding()
            case .recentRequests, .unknown:
                EmptyView()
            }
            VStack {
                switch viewType {
                case .flightCrew, .cabinCrew, .unknown:
                    Group {
                        Text("Make your selections using the controls on the left;")
                            .padding()
                        Text("Calculation results will be shown here.")
                            .padding()
                    }.font(.title2)
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

                        Text("🔄 Try rotating your iPad to landscape mode for a different experience! 🔄")

                    }.font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
                }
            }
        }.multilineTextAlignment(.center)
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
            WelcomeView(viewType: .flightCrew)
            WelcomeView(viewType: .cabinCrew)
            WelcomeView(viewType: .recentRequests)
        }
    }
}
