//
//  Task.swift
//  SimpleTodo
//
//  Created by Александр Калашников on 14.09.2024.
//

import Foundation
struct Task: Decodable, Hashable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct Query: Decodable {
    let todos: [Task]
}
