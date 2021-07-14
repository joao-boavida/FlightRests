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

    var body: some View {
        NavigationView {
            if requestLog.requests.isEmpty {
                ZStack {
                    Color.gray
                        .opacity(0.3)
                    Text("Previous rest calculations will be shown here.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                }.navigationBarTitle("Recent Rests")
            } else {
                List {
                    ForEach(requestLog.requests.sorted().reversed(), id: \.self) { request in
                        RestRequestView(request: request)
                    }
                    .onDelete(perform: delete)
                }.navigationBarTitle("Recent Rests")
            }
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
