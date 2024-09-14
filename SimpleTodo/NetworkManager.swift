//
//  NetworkManager.swift
//  SimpleTodo
//
//  Created by Александр Калашников on 14.09.2024.
//

import Foundation
import SwiftUI
import CoreData

final class NetworkManager: ObservableObject {
    
    init() {
        checkFirstLaunch()
    }
    
    static let shared = NetworkManager()
    
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @Published var tasks = [Task]()
    
    private var isFirstLaunch: Bool = false
    
    func fetchTasks(viewContext: NSManagedObjectContext) {
        if isFirstLaunch {
            guard let url = URL(string: "https://dummyjson.com/todos") else { return }
            let fetchRequest = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: fetchRequest) { [weak self] (data, response, error) -> Void in
                if error != nil {
                    
                } else {
                    guard let safeData = data else { return }
                    
                    if let decodedQuery = try? JSONDecoder().decode(Query.self, from: safeData) {
                        DispatchQueue.main.async {
                            self?.tasks = decodedQuery.todos
                            DispatchQueue.main.async {
                                for task in decodedQuery.todos {
                                    let newItem = Item(context: viewContext)
                                    newItem.timeCreate = Date()
                                    newItem.name = task.todo
                                    newItem.overview = task.todo
                                    newItem.completed = task.completed
                                }
                                
                                // Сохранение контекста вне цикла, после завершения всех операций
                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        }
                        
                    }
                }
            }.resume()
        }
    }

    
    private func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard
        
        // Проверяем, есть ли запись о том, что приложение уже запускалось
        if !userDefaults.bool(forKey: "hasLaunchedBefore") {
            // Если нет, значит это первый запуск
            isFirstLaunch = true
            
            // Сохраняем, что приложение было запущено
            userDefaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
}
