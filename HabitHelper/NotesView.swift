import SwiftUI

struct NotesView: View {
    @State private var noteText: String = UserDefaults.standard.string(forKey: "noteText") ?? ""

    var body: some View {
        VStack {
            Text("记事本")
                .font(.title)
                .padding()

            TextEditor(text: $noteText)
                .padding()
                .border(Color.gray, width: 1)
                .frame(width: 400, height: 300)

            Button("保存") {
                UserDefaults.standard.set(noteText, forKey: "noteText")
            }
            .padding()
        }
        .padding()
    }
}//
//  NotesView.swift
//  HabitHelper
//
//  Created by 刘晋宁 on 2025/3/4.
//

