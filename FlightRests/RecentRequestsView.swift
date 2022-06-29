//
//  RecentRequestsView.swift
//  FlightRests
//
//  Created by Joao Boavida on 12/03/2021.
//

import SwiftUI

/// A view which shows recently created rest requests
struct RecentRequestsView: View {

    /// database of requests to be used in the RecentRequestsView
    @ObservedObject var requestLog: RequestLog

    /// clears the request log
    func clearLog() {
        withAnimation {
            requestLog.clearLog()
        }
    }

    /// triggers the deletion confirmation alert
    func showAlert() {
        showingClearAlert = true
    }

    /// Manages the appearance of an alert when the user attempts to clear all entries
    @State private var showingClearAlert = false

    /// constants for the text shown in the UI
    let alertTitle = "Delete all rest plans?"

    let alertMessage = "All the rest plans stored in this device will be deleted; this action cannot be undone."

    let emptyListMessage = "Your previously calculated rest plans will be shown here."

    let viewTitle = "Recent Rests"

    var body: some View {
        NavigationView {
            if requestLog.requests.isEmpty {
                ZStack {
                    Color.gray
                        .opacity(0.1)
                    VStack {
                        Image(systemName: DefaultValues.recentsIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .frame(maxHeight: 100)
                        Text(emptyListMessage)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                    }.foregroundColor(.secondary)
                }.navigationBarTitle(viewTitle, displayMode: .inline)
            } else {
                List {
                    ForEach(requestLog.requests.sorted().reversed(), id: \.self) { request in
                        RestRequestView(request: request)
                    }
                    .onDelete(perform: delete)
                    .transition(.slide)
                }.navigationBarTitle(viewTitle, displayMode: .inline)
                    .toolbar {
                        Button(action: showAlert) {
                            Image(systemName: "trash")
                        }
                    }
                    .alert(alertTitle, isPresented: $showingClearAlert, actions: {
                        Button("Delete All", role: .destructive) {
                            clearLog()
                            // the clear all notification is sent so that the restplan view, if visible, will clear any results being shown
                            NotificationManager.postClearAllNotification()
                        }
                        Button("Cancel", role: .cancel) {
                            showingClearAlert = false
                        }
                    }, message: {
                        Text(alertMessage)
                    })
            }
            WelcomeView(viewType: .recentRequests)
        }
    }

    /// Function called by the delete gesture which triggers the deletion of the specified rest request.
    /// - Parameter offsets: offsets sent by the swipe to delete gesture
    func delete(at offsets: IndexSet) {
        let elementToRemove = offsets.map { requestLog.requests.sorted().reversed()[$0]}.first

        guard let elementToRemove = elementToRemove else { return }

        requestLog.removeRequest(elementToRemove)
    }
}

struct RecentRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentRequestsView(requestLog: RequestLog())
    }
}
