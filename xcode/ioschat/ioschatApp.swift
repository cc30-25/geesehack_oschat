//
//  ioschatApp.swift
//  ioschat
//
//  Created by cilo chou on 2025-01-25.
//

import SwiftUI

@main
struct ioschatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            //            ContentView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            HomeView()
        }
    }
}
