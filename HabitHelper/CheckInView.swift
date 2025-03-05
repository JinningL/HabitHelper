import SwiftUI

struct CheckInView: View {
    @State private var currentDate = Date()
    @State private var showNewTaskInput = false
    @State private var newTaskName = ""
    @State private var selectedDays: [Int] = []
    @State private var tasks: [[String: Any]] = UserDefaults.standard.array(forKey: "taskList") as? [[String: Any]] ?? []
    @State private var showSelectDaysView = false
    @State private var isOneTime = false
    @State private var completedTasks: [String] = []

    var body: some View {
        VStack {
            HStack {
                Button("←") { changeDate(by: -1) }
                Text(formattedDate(currentDate))
                    .font(.title)
                    .padding(.horizontal)
                Button("→") { changeDate(by: 1) }
            }
            .padding()

            Text("今日打卡任务")
                .font(.headline)

            if todayTasks().isEmpty {
                Text("今日无打卡任务")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(todayTasks(), id: \.self) { task in
                    HStack {
                        Text(task)
                        Spacer()
                        if completedTasks.contains(task) {
                            Text("✅ 已完成")
                                .foregroundColor(.green)
                        } else {
                            Button("打卡") {
                                saveCheckIn(taskName: task)
                            }
                        }
                    }
                    .padding()
                }
            }

            Divider().padding()

            Text("打卡任务列表")
                .font(.headline)

            ForEach(tasks.indices, id: \.self) { index in
                let task = tasks[index]
                if let name = task["name"] as? String {
                    HStack {
                        Text(name)
                        Spacer()
                        Button(role: .destructive) {
                            deleteTask(at: index)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Button("➕ 新建打卡类型") {
                showNewTaskInput.toggle()
            }
            .padding()

            if showNewTaskInput {
                VStack {
                    TextField("请输入打卡名称", text: $newTaskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Text("选择打卡类型")
                    Picker("类型", selection: $isOneTime) {
                        Text("一次").tag(true)
                        Text("自定义星期几").tag(false)
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    .padding()

                    if !isOneTime {
                        Button("设置星期几") {
                            showSelectDaysView = true
                        }
                        .padding()
                    }

                    Button("保存打卡类型") {
                        addNewTask()
                    }
                    .padding()
                }
                .padding()
                .sheet(isPresented: $showSelectDaysView) {
                    SelectDaysView(selectedDays: $selectedDays)
                }
            }
        }
        .padding()
        .onAppear {
            loadCompletedTasks()
        }
    }

    func deleteTask(at index: Int) {
        let removedTask = tasks.remove(at: index)
        UserDefaults.standard.set(tasks, forKey: "taskList")

        if let removedTaskName = removedTask["name"] as? String {
            var records = UserDefaults.standard.array(forKey: "checkInRecords") as? [[String: Any]] ?? []
            for i in 0..<records.count {
                var record = records[i]
                if var tasks = record["tasks"] as? [String] {
                    tasks.removeAll { $0 == removedTaskName }
                    record["tasks"] = tasks
                    records[i] = record
                }
            }
            UserDefaults.standard.set(records, forKey: "checkInRecords")
        }
    }

    func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) {
            currentDate = newDate
            loadCompletedTasks()
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    func todayTasks() -> [String] {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let today = Calendar.current.startOfDay(for: Date())
        let currentDay = Calendar.current.startOfDay(for: currentDate)

        if currentDay < today {
            return []
        }

        return tasks.compactMap { task in
            guard let name = task["name"] as? String else { return nil }

            if let date = task["date"] as? Date {
                if Calendar.current.isDate(date, inSameDayAs: currentDate) {
                    return name
                } else {
                    return nil
                }
            }

            if let days = task["days"] as? [Int] {
                return days.contains(weekday) ? name : nil
            }

            return nil
        }
    }

    func addNewTask() {
        guard !newTaskName.isEmpty else { return }
        if isOneTime {
            tasks.append(["name": newTaskName, "date": currentDate])
        } else {
            tasks.append(["name": newTaskName, "days": selectedDays])
        }
        UserDefaults.standard.set(tasks, forKey: "taskList")
        newTaskName = ""
        selectedDays = []
        showNewTaskInput = false
    }

    func saveCheckIn(taskName: String) {
        let today = Calendar.current.startOfDay(for: currentDate)
        var records = UserDefaults.standard.array(forKey: "checkInRecords") as? [[String: Any]] ?? []
        let calendar = Calendar.current

        if let index = records.firstIndex(where: { record in
            if let date = record["date"] as? Date {
                return calendar.isDate(date, inSameDayAs: today)
            }
            return false
        }) {
            var todayRecord = records[index]
            var tasks = todayRecord["tasks"] as? [String] ?? []
            if !tasks.contains(taskName) {
                tasks.append(taskName)
                todayRecord["tasks"] = tasks
                records[index] = todayRecord
            }
        } else {
            records.append(["date": today, "tasks": [taskName]])
        }

        UserDefaults.standard.set(records, forKey: "checkInRecords")
        loadCompletedTasks()
    }

    func loadCompletedTasks() {
        let today = Calendar.current.startOfDay(for: currentDate)
        let records = UserDefaults.standard.array(forKey: "checkInRecords") as? [[String: Any]] ?? []
        let calendar = Calendar.current

        completedTasks = records.first(where: { record in
            if let date = record["date"] as? Date {
                return calendar.isDate(date, inSameDayAs: today)
            }
            return false
        })?["tasks"] as? [String] ?? []
    }
}
