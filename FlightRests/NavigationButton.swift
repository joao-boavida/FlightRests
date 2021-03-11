//
//  NavigationButton.swift
//  FlightRests
//
//  Created by Joao Boavida on 10/03/2021.
//

import SwiftUI

/// Looks like a navigation link but will perform an action before activating the link.
struct NavigationButton<Destination: View>: View {

    let destination: Destination
    var title: String = "Default Title"
    var handler: (() -> Void)?

    @State private var navigationLinkActive = false

    var body: some View {
        ZStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Spacer()
            }.onTapGesture {
                handler?()
                navigationLinkActive = true
            }
            NavigationLink(destination: destination, isActive: $navigationLinkActive) {
                EmptyView()
            }
        }
    }
}

struct NavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                NavigationButton(destination: Text("Test"))
                NavigationButton(destination: Text("Test Print"), title: "Print 123") {
                    print("Test Print")
                }
            }
        }
    }
}
