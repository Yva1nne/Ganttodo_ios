import SwiftUI
import SwiftData
import WidgetKit

struct TaskListView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Task.plannedDateStart) var tasks: [Task]
    
    @State private var showingAddTask = false
    @State private var showingSettings = false
    @State private var taskToEdit: Task?
    
    @State private var overdueExpanded = true
    @State private var todayExpanded = true
    @State private var upcomingExpanded = true
    @State private var laterExpanded = false
    @State private var isCompletedExpanded = true

    // MARK: - Computed Properties
    private var overdueTasks: [Task] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let filtered = tasks.filter { !$0.isCompleted && $0.plannedDateEnd < startOfToday }
        return filtered.sorted(by: { $0.plannedDateEnd < $1.plannedDateEnd })
    }
    private var todayTasks: [Task] {
        let today = Calendar.current.startOfDay(for: Date())
        let filtered = tasks.filter { !$0.isCompleted && $0.plannedDateStart <= today && $0.plannedDateEnd >= today }
        return filtered.sorted(by: { $0.plannedDateStart < $1.plannedDateStart })
    }
    private var upcomingTasks: [Task] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let startOfTomorrow = Calendar.current.startOfDay(for: tomorrow)
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfTomorrow)!
        let filtered = tasks.filter { !$0.isCompleted && ($0.plannedDateStart >= startOfTomorrow && $0.plannedDateStart < nextWeek) }
        return filtered.sorted(by: { $0.plannedDateStart < $1.plannedDateStart })
    }
    private var laterTasks: [Task] {
        let startOfNextWeek = Calendar.current.date(byAdding: .day, value: 8, to: Calendar.current.startOfDay(for: Date()))!
        let filtered = tasks.filter { !$0.isCompleted && $0.plannedDateStart >= startOfNextWeek }
        return filtered.sorted(by: { $0.plannedDateStart < $1.plannedDateStart })
    }
    private var completedTasks: [Task] {
        let filtered = tasks.filter { $0.isCompleted }
        return filtered.sorted { ($0.completionDate ?? $0.plannedDateStart) > ($1.completionDate ?? $1.plannedDateStart) }
    }
    private var groupedCompletedTasks: [String: [Task]] {
        Dictionary(grouping: completedTasks, by: groupKeyForCompletedTask)
    }
    private var sortedCompletedTaskKeys: [String] {
        // This custom sort can handle the different date formats from the group keys
        groupedCompletedTasks.keys.sorted { key1, key2 in
            guard let date1 = dateFromGroupKey(key1), let date2 = dateFromGroupKey(key2) else {
                return key1 > key2
            }
            return date1 > date2
        }
    }

    var body: some View {
        NavigationView {
            List {
                DisclosureGroup("已过期 (\(overdueTasks.count))", isExpanded: $overdueExpanded) {
                    ForEach(overdueTasks) { task in
                        TaskRowView(task: task, onEdit: { taskToEdit = task })
                    }
                    .onDelete { indexSet in deleteTasks(at: indexSet, from: overdueTasks) }
                }.tint(.red)
                
                DisclosureGroup("今天 (\(todayTasks.count))", isExpanded: $todayExpanded) {
                    ForEach(todayTasks) { task in
                        TaskRowView(task: task, onEdit: { taskToEdit = task })
                    }
                    .onDelete { indexSet in deleteTasks(at: indexSet, from: todayTasks) }
                }.tint(.primary)
                
                DisclosureGroup("即将到来 (\(upcomingTasks.count))", isExpanded: $upcomingExpanded) {
                    ForEach(upcomingTasks) { task in
                        TaskRowView(task: task, onEdit: { taskToEdit = task })
                    }
                    .onDelete { indexSet in deleteTasks(at: indexSet, from: upcomingTasks) }
                }.tint(.primary)

                DisclosureGroup("稍后 (\(laterTasks.count))", isExpanded: $laterExpanded) {
                    ForEach(laterTasks) { task in
                        TaskRowView(task: task, onEdit: { taskToEdit = task })
                    }
                    .onDelete { indexSet in deleteTasks(at: indexSet, from: laterTasks) }
                }.tint(.primary)
                
                Section(header: Text("已完成")) {
                    if completedTasks.isEmpty {
                        Text("没有已完成的任务").foregroundColor(.secondary)
                    } else {
                        ForEach(sortedCompletedTaskKeys, id: \.self) { key in
                            DisclosureGroup(key) {
                                let tasksInGroup = groupedCompletedTasks[key] ?? []
                                //
                                // MARK: - Request 1: Re-enable swipe-to-delete by iterating over indices
                                //
                                ForEach(tasksInGroup.indices, id: \.self) { index in
                                    let task = tasksInGroup[index]
                                    TaskRowView(task: task, onEdit: { taskToEdit = task })
                                }
                                .onDelete { indexSet in
                                    deleteTasks(at: indexSet, from: tasksInGroup)
                                }
                            }
                            .tint(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("任务列表")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddTask) { EditTaskView(task: Task(title: "")) }
            
            .sheet(item: $taskToEdit) { task in EditTaskView(task: task) }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    //
    // MARK: - Request 2: New dynamic grouping logic
    //
    private func groupKeyForCompletedTask(_ task: Task) -> String {
        let calendar = Calendar.current
        let date = task.completionDate ?? task.plannedDateStart
        
        if calendar.isDateInThisWeek(date) {
            // Within this week, group by day
            return DateFormatter.yyyyMMdd.string(from: date)
        } else if calendar.isDateInThisMonth(date) {
            // Within this month (but not week), group by week
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
                return DateFormatter.yyyyMMdd.string(from: date)
            }
            let startOfWeek = DateFormatter.yyyyMMdd.string(from: weekInterval.start)
            let endOfWeek = DateFormatter.yyyyMMdd.string(from: weekInterval.end)
            return "\(startOfWeek) - \(endOfWeek)"
        } else if calendar.isDateInThisYear(date) {
            // Within this year (but not month), group by month
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM"
            return formatter.string(from: date)
        } else {
            // Older than this year, group by year
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: date)
        }
    }
    
    // Helper function to parse dates from various key formats for sorting
    private func dateFromGroupKey(_ key: String) -> Date? {
        if let date = DateFormatter.yyyyMMdd.date(from: key) {
            return date
        }
        if let date = DateFormatter.yyyyMMdd.date(from: String(key.prefix(10))) { // "yyyy/MM/dd - ..."
            return date
        }
        let monthFormatter = DateFormatter(); monthFormatter.dateFormat = "yyyy/MM"
        if let date = monthFormatter.date(from: key) {
            return date
        }
        let yearFormatter = DateFormatter(); yearFormatter.dateFormat = "yyyy"
        if let date = yearFormatter.date(from: key) {
            return date
        }
        return nil
    }
    private func delete(task: Task) {
        withAnimation {
            context.delete(task)
            // 2. 立即保存数据到磁盘
            try? context.save()
            // 3. 确认保存后，再通知小组件刷新
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func deleteTasks(at offsets: IndexSet, from taskArray: [Task]) {
        // withAnimation 包含在 delete(task:) 中
        for index in offsets {
            let taskToDelete = taskArray[index]
            delete(task: taskToDelete) // 调用已修复的
        }
    }
}
