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

    @State private var showingClearAlert = false

    let alertString = "Do you wish to delete all entries in this list?"

    var body: some View {
        NavigationView {
            if requestLog.requests.isEmpty {
                ZStack {
                    Color.gray
                        .opacity(0.1)
                    Text("Recent rest calculations will be shown here.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .opacity(0.5)
                }.navigationBarTitle("Recent Rests", displayMode: .inline)
            } else {
                List {
                    ForEach(requestLog.requests.sorted().reversed(), id: \.self) { request in
                        RestRequestView(request: request)
                    }
                    .onDelete(perform: delete)
                    .transition(.slide)
                }.navigationBarTitle("Recent Rests", displayMode: .inline)
                    .toolbar {
                        Button(action: showAlert) {
                            Image(systemName: "trash")
                        }
                    }
                    .alert(alertString, isPresented: $showingClearAlert) {
                        Button("Cancel", role: .cancel) {
                            showingClearAlert = false
                        }
                        Button("Delete All", role: .destructive) {
                            clearLog()
                            NotificationManager.postClearAllNotification()
                        }
                    }
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
