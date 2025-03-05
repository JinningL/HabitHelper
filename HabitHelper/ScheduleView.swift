import SwiftUI
import UserNotifications

struct ScheduleView: View {
    @State private var schedules: [[String: Any]] = UserDefaults.standard.array(forKey: "schedules") as? [[String: Any]] ?? []
    @State private var newTitle = ""
    @State private var newDate = Date()

    var body: some View {
        VStack(alignment: .leading) {
            Text("📅 已有日程")
                .font(.headline)
                .padding(.bottom, 5)

            if schedules.isEmpty {
                Text("暂无日程")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            } else {
                List {
                    ForEach(Array(schedules.enumerated()), id: \.offset) { index, schedule in
                        if let title = schedule["title"] as? String,
                           let date = schedule["date"] as? Date {
                            HStack {
                                Text("\(formattedDate(date)) - \(title)")
                                Spacer()
                                Button("删除") {
                                    deleteSchedule(at: index)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }

            Divider().padding(.vertical, 10)

            Text("➕ 新建日程")
                .font(.headline)
                .padding(.bottom, 5)

            TextField("请输入日程名称", text: $newTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)

            DatePicker("提醒时间", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(FieldDatePickerStyle())
                .padding(.bottom, 10)

            Button("保存日程") {
                addSchedule()
            }
            .padding()

        }
        .padding()
        .frame(width: 400, height: 500)
        .onAppear {
            requestNotificationPermission()
        }
    }

    // MARK: - 添加日程
    func addSchedule() {
        guard !newTitle.isEmpty else { return }
        let newSchedule: [String: Any] = ["title": newTitle, "date": newDate]
        schedules.append(newSchedule)
        UserDefaults.standard.set(schedules, forKey: "schedules")
        scheduleNotification(title: newTitle, date: newDate)
        newTitle = ""
        newDate = Date()
    }

    // MARK: - 删除日程
    func deleteSchedule(at index: Int) {
        schedules.remove(at: index)
        UserDefaults.standard.set(schedules, forKey: "schedules")
    }

    // MARK: - 请求通知权限
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print(granted ? "通知权限已授予" : "通知权限被拒绝")
        }
    }

    // MARK: - 日程通知
    func scheduleNotification(title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "📌 日程提醒"
        content.body = title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 时间格式化
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}
