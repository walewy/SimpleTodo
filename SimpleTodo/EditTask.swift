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
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    @State var item: Item
    @State var name: String
    @State var overview: String
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading, spacing: 10) {
                TextEditor(text: $name)
                    .font(.title2)
                    .frame(minHeight: 50, idealHeight: 50, maxHeight: 50)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .padding(.bottom, 10)
                
                // Многострочное текстовое поле для описания
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
                Button {
                    DispatchQueue.global(qos: .utility).async {
                        item.name = self.name
                        item.overview = self.overview
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
