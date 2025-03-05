import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack {
            Text("日历")
                .font(.largeTitle)
                .padding()

            DatePicker(
                "",
                selection: .constant(Date()),
                displayedComponents: [.date]
                
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .frame(width: 520, height: 480)
            .padding()
            .scaleEffect(1.5)
        }
        .padding()
    }
}//
//  CalendarView.swift
//  HabitHelper
//
//  Created by 刘晋宁 on 2025/3/4.
//

