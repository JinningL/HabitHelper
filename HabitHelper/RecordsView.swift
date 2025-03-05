import SwiftUI

struct RecordsView: View {
    @State private var currentWeek: Date = Date()
    @State private var habits: [String: [Bool]] = [:]
    @State private var allTasks: [String] = []

    var body: some View {
        VStack {
            let weekDates = getWeekDates(for: currentWeek)
            let startOfWeek = formattedDate(weekDates.first!)
            let endOfWeek = formattedDate(weekDates.last!)

            // ✅ 顶部显示本周日期范围（周一到周日）
            HStack {
                Button("上一周") {
                    currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? Date()
                    loadRecords()
                }

                Text("\(startOfWeek) - \(endOfWeek)")
                    .font(.title)

                Button("下一周") {
                    currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? Date()
                    loadRecords()
                }
            }
            .padding()

            VStack(alignment: .leading) {
                // ✅ 顶部日期标题：周一到周日
                HStack {
                    Text("习惯")
                        .frame(width: 100, alignment: .leading)
                    ForEach(weekDates, id: \.self) { date in
                        Text(weekdayName(date))
                            .frame(width: 50)
                            .foregroundColor(.blue)
                    }
                }
                .font(.headline)
                .padding()

                Divider()

                ForEach(allTasks, id: \.self) { habitName in
                    HStack {
                        Text(habitName)
                            .frame(width: 100, alignment: .leading)

                        ForEach(0..<7, id: \.self) { index in
                            let date = weekDates[index]
                            let isFuture = date > Date()
                            let taskStatus = habits[habitName]?[index] ?? false
                            let isScheduled = isTaskScheduled(habitName: habitName, weekdayIndex: (index + 2) % 7 + 1)

                            if isFuture {
                                Image(systemName: "circle")
                                    .foregroundColor(Color.black.opacity(0.1))
                                    .frame(width: 30, height: 30)
                            } else if isScheduled {
                                Image(systemName: taskStatus ? "circle.fill" : "circle")
                                    .foregroundColor(taskStatus ? .green : .red)
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .onAppear {
            loadRecords()
        }
    }

    func loadRecords() {
        let records = UserDefaults.standard.array(forKey: "checkInRecords") as? [[String: Any]] ?? []
        let tasks = UserDefaults.standard.array(forKey: "taskList") as? [[String: Any]] ?? []
        let weekDates = getWeekDates(for: currentWeek)
        let calendar = Calendar.current

        habits = [:]
        allTasks = []

        for task in tasks {
            if let name = task["name"] as? String {
                allTasks.append(name)
                habits[name] = Array(repeating: false, count: 7)
            }
        }

        for (index, date) in weekDates.enumerated() {
            for record in records {
                if let recordDate = record["date"] as? Date,
                   calendar.isDate(recordDate, inSameDayAs: date),
                   let tasks = record["tasks"] as? [String] {
                    for task in tasks {
                        if habits[task] == nil {
                            allTasks.append(task)
                            habits[task] = Array(repeating: false, count: 7)
                        }
                        habits[task]?[index] = true
                    }
                }
            }
        }
    }

    func isTaskScheduled(habitName: String, weekdayIndex: Int) -> Bool {
        let taskList = UserDefaults.standard.array(forKey: "taskList") as? [[String: Any]] ?? []
        if let task = taskList.first(where: { $0["name"] as? String == habitName }) {
            if let days = task["days"] as? [Int] {
                return days.contains(weekdayIndex)
            }
            if let date = task["date"] as? Date {
                let weekday = Calendar.current.component(.weekday, from: date)
                return weekday == weekdayIndex
            }
        }
        return false
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    func weekdayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    func getWeekDates(for date: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // ✅ 设置周一为每周第一天
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = calendar.date(from: components)!

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}
