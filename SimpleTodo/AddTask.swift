//
//  AddTask.swift
//  SimpleTodo
//
//  Created by Александр Калашников on 11.09.2024.
//

import Foundation
import SwiftUI

struct AddTask: View {
    
    @State private var taskName: String = ""
    @State private var taskOverview: String = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        VStack {
            Text("Add new task")
                .font(.title)
                .fontWeight(.semibold)
            
            Spacer()
            
            VStack(spacing: 10) {
                TextField(text: $taskName) {
                    Text("Enter title: ")
                        .font(.headline)
                        .bold()
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                }
                TextField(text: $taskOverview) {
                    Text("Enter description: ")
                        .font(.headline)
                        .bold()
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                }
                
                Button(action: {
                    let newItem = Item(context: viewContext)
                    newItem.timeCreate = Date()
                    newItem.name = self.taskName
                    newItem.overview = self.taskOverview
                    newItem.completed = false
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
//                    print(items)
                    dismiss()
                }, label: {
                    Text("Add")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        }
                })
            }
            
            Spacer()
        }
        .padding()
    }
    
}

#Preview {
    AddTask().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
