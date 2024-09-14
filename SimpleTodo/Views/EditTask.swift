//
//  EditTask.swift
//  SimpleTodo
//
//  Created by Александр Калашников on 13.09.2024.
//

import Foundation
import SwiftUI

struct EditTask: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var item: Item
    @State var name: String
    @State var overview: String
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading, spacing: 10) {
                // Многострочное текстовое поле для заголовка задачи
                TextEditor(text: $name)
                    .font(.title2)
                    .frame(minHeight: 50, idealHeight: 50, maxHeight: 50)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                    .padding(.bottom, 10)
                
                // Многострочное текстовое поле для описания задачи
                TextEditor(text: $overview)
                    .font(.subheadline)
                    .frame(minHeight: 150, idealHeight: 150) // Ограничение на начальную высоту
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Кнопка для сохранения изменений
                Button {
                    // Создаем асинхронную очередь с качеством .utility
                    DispatchQueue.global(qos: .utility).async {
                        // Передаем в текущий итем измененные заголовок и описание
                        item.name = self.name
                        item.overview = self.overview
                        // для сохранения контекста переходим в основной поток
                        DispatchQueue.main.async {
                            do {
                                try viewContext.save()
                            } catch {
                                print("obshibka v EDIT TASK NA MOMENT SOXRANENIYA")
                            }
                        }
                    }
                } label: {
                    Text("Save")
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let newItem = Item(context: context) // Создаем временный объект
    newItem.name = "Test Task"
    newItem.overview = "Test Overview"
    
    return EditTask(item: newItem, name: newItem.name ?? "", overview: newItem.overview ?? "")
        .environment(\.managedObjectContext, context)
}
