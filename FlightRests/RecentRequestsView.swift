//
//  RecentRequestsView.swift
//  FlightRests
//
//  Created by Joao Boavida on 12/03/2021.
//

import SwiftUI

struct RecentRequestsView: View {

    /// database of requests to be used in the RecentRequestsView
    @ObservedObject var requestLog: RequestLog

    var body: some View {
        NavigationView {
            List {
                ForEach(requestLog.requests.sorted(), id: \.self) { request in
                    RestRequestView(request: request)
                }
            }.navigationBarTitle("Recent Rests")
        }
    }
}

struct RecentRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentRequestsView(requestLog: RequestLog())
    }
}
