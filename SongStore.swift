//
//  SongStore.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//

import Foundation

// ObservableObject allows us to share this across views and auto-update UI when data changes
class SongStore: ObservableObject {
    // Published = any changes to this array will refresh any views using it
    @Published var submissions: [SongSubmission] = []
}
