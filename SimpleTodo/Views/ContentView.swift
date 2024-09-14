//
//  ContentView.swift
//  SimpleTodo
//
//  Created by Александр Калашников on 11.09.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    enum ActiveFilter {
        case all
        case open
        case closed
    }
    
    // объект NetworkManager
    @StateObject var networkManager = NetworkManager.shared
    
    // контекст
    @Environment(\.managedObjectContext) private var viewContext
    
    // получаем элементы из CoreData
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    
    // текущий фильтр
//    @State private var activeFilter: String = "All"
    @State private var activeFilter: ActiveFilter = .all
    
    var body: some View {
        NavigationView {
            VStack{
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today's Task")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("\(Date().formatted(Date.FormatStyle().day(.twoDigits).weekday(.wide).month(.wide  )))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .onAppear {
                        networkManager.fetchTasks()
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        AddTask()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Task")
                        }
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                HStack() {
                    FilterButton(label: "All", count: items.count, isActive: activeFilter == .all) {
                        activeFilter = .all
                    }
                    FilterButton(label: "Open", count: returnCount(open: true), isActive: activeFilter == .open) {
                        activeFilter = .open
                    }
                    FilterButton(label: "Closed", count: returnCount(open: false), isActive: activeFilter == .closed) {
                        activeFilter = .closed
                    }
                }
                
                // Список задач
                List {
                    ForEach(items) { item in
                        // Если выбран пункт "All", то берем все элементы из списка
                        if activeFilter == .all {
                            ListElement(item: item)
                            // Если выбран фильтр "Open", то отбираем элементы, у которых completed = false
                        } else if activeFilter == .open {
                            if !item.completed {
                                ListElement(item: item)
                            }
                            // Если выбран фильтр "Closed", то отбираем элементы, у которых completed = true
                        } else if activeFilter == .closed {
                            if item.completed {
                                ListElement(item: item)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems) // Обработка удаления
                    .listRowSeparator(.hidden)
                }
                .listStyle(.inset)
                
            }
        }
    }
    
    // функция возвращающая количество элементов (Open, Closed)
    func returnCount(open: Bool) -> Int {
        
        var count = 0
        
        for item in items {
            if open {
                if !item.completed {
                    count += 1
                }
            } else {
                if item.completed {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    struct ListElement: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        @ObservedObject var item: Item
        
        var body: some View {
            ZStack {
                NavigationLink(destination: EditTask(item: item, name: item.name ?? "some name", overview: item.overview ?? "some overview")) {
                    EmptyView() // Невидимый элемент для навигации
                }
                .opacity(0) // Прячем стрелку и сам `NavigationLink`, но сохраняем логику навигации
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            // Вертикальный стэк с заголовком и описанием
                            VStack(alignment: .leading) {
                                // заголовок
                                Text(item.name ?? "some name")
                                    .strikethrough(item.completed ? true : false, color: .black)
                                    .font(.headline)
                                
                                // описание
                                Text(item.overview ?? "some overview")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Картинка по нажатию которой отмечается выполнение или не выполнение задачи
                            Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue)
                                .font(.title)
                                // по нажатию меняем completed и сохраняем контекст
                                .onTapGesture {
                                    item.completed.toggle()
                                    // переходим в основной поток
                                    DispatchQueue.main.async {
                                        do {
                                            // пытаемся сохранить контекст
                                            try viewContext.save()
                                        } catch {
                                            print("Problems with context saving")
                                        }
                                    }
                                }
                        }
                        
                        Divider()
                        
                        // Отображаем время создания задачи
                        Text(item.timeCreate?.formatted(Date.FormatStyle().day(.twoDigits).weekday(.wide).month(.wide)) ?? "123")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            }
        }
    }
    
    
    struct FilterButton: View {
        var label: String
        var count: Int
        var isActive: Bool
        var action: () -> Void
        
        
        var body: some View {
            Button(action: {
                action() // Выполняется переданная функция при нажатии
            }) {
                HStack {
                    Text("\(label)")
                        .fontWeight(isActive ? .bold : .regular)
                        .foregroundColor(isActive ? .blue : .gray)
                    Text("\(count)")
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(isActive ? .blue : .gray.opacity(0.7))
                        }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
