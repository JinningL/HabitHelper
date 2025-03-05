import SwiftUI

struct SelectDaysView: View {
    @Binding var selectedDays: [Int]
    @Environment(\.dismiss) var dismiss  // 用于关闭页面
    
    var body: some View {
        VStack {
            Text("选择打卡的星期几")
                .font(.headline)
                .padding()
            
            ForEach(1...7, id: \.self) { day in
                Toggle(weekdayName(day), isOn: Binding(
                    get: { selectedDays.contains(day) },
                    set: { isSelected in
                        if isSelected {
                            selectedDays.append(day)
                        } else {
                            selectedDays.removeAll { $0 == day }
                        }
                    }
                ))
            }
            .padding()
            
            Button("✅ 确定") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}

func weekdayName(_ day: Int) -> String {
    let names = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    return names[day - 1]
}
