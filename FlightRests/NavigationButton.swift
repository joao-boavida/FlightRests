//
//  NavigationButton.swift
//  FlightRests
//
//  Created by Joao Boavida on 10/03/2021.
//

import SwiftUI

//bug: when the text is pressed the closure is triggered, otherwise it is not

/// Looks like a navigation link but will perform an action before activating the link.
struct NavigationButton<Destination: View>: View {

    let destination: Destination
    var title: String = "Default Title"
    var handler: (() -> Void)?

    @State private var navigationLinkActive = false

    var body: some View {
        ZStack {
            NavigationLink(destination: destination, isActive: $navigationLinkActive) {
                EmptyView()
            }.allowsHitTesting(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
            HStack {
                Button(title) {
                    handler?()
                    navigationLinkActive = true
                }.font(.headline)
                Spacer()
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
