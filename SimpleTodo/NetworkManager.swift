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
    
    // Говорит первый это запуск приложения или нет
    private var isFirstLaunch: Bool = false
    
    // Контекст
    private var viewContext = PersistenceController.shared.container.viewContext
    
    // Функция, которая загружает с json'a задания и сразу сгружает их в CoreData
    func fetchTasks() {
        // Если первый запуск то загружаем задания из сети и сгружаем в CoreData
        if self.isFirstLaunch {
            // Переходим в асинхронную очередь с качеством .utility
            DispatchQueue.global(qos: .utility).async {
                // Создаем ссылку url на json
                guard let url = URL(string: "https://dummyjson.com/todos") else { return }
                // Создаем запрос на url
                let fetchRequest = URLRequest(url: url)
                
                // Создаем url sesson в котором обрабатываем запрос
                URLSession.shared.dataTask(with: fetchRequest) { [weak self] (data, response, error) -> Void in
                    // Если ошибки нет то мы продолжаем
                    if error != nil {
                        
                    } else {
                        // Избавляемся от опциональности
                        guard let safeData = data else { return }
                        
                        // Декодируем полученные данные в переменную decodedQuery, которая имеет тип Query и сразу избавляемся от опциональности
                        if let decodedQuery = try? JSONDecoder().decode(Query.self, from: safeData) {
                            
                            // Создаем очередь в главном потоке
                            DispatchQueue.main.async {
                                
                                // Проходимся фором по заданиям из полученного ответа
                                for task in decodedQuery.todos {
                                    // Создаем новый айтем в CoreData
                                    let newItem = Item(context: self!.viewContext)
                                    //Присаваиваем итему все нужные нам параметры(или это атрибутом правильно называть)
                                    newItem.timeCreate = Date()
                                    newItem.name = task.todo
                                    newItem.overview = task.todo
                                    newItem.completed = task.completed
                                }
                                
                                // Сохраняем контекст
                                do {
                                    try self?.viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        }
                    }
                }.resume()
            }
        }
    }
    
    // Функция, которая проверяет является ли текущий запуск первым
    private func checkFirstLaunch() {
        // Переходим в асинхронную очередь с качеством .utility
        DispatchQueue.global(qos: .utility).async {
            let userDefaults = UserDefaults.standard
            
            // Проверяем, есть ли запись о том, что приложение уже запускалось
            if !userDefaults.bool(forKey: "hasLaunchedBefore") {
                // Если нет, значит это первый запуск
                self.isFirstLaunch = true
                
                // Сохраняем, что приложение было запущено
                userDefaults.set(true, forKey: "hasLaunchedBefore")
            }
        }
    }
    
}
