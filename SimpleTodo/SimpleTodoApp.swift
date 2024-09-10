//
//  SimpleTodoApp.swift
//  SimpleTodo
//
//  Created by Александр Калашников on 11.09.2024.
//

import SwiftUI

@main
struct SimpleTodoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
