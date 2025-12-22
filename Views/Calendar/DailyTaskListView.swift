import SwiftUI
import SwiftData

struct DailyTaskListView: View {
    let selectedDate: Date
    @State private var taskToEdit: Task?

    var body: some View {
        List {
            DailyTaskQueryView(selectedDate: selectedDate, taskToEdit: $taskToEdit)
        }
        .navigationTitle(DateFormatter.yyyyMMdd.string(from: selectedDate))
        .sheet(item: $taskToEdit) { task in
            EditTaskView(task: task)
        }
    }
}

private struct DailyTaskQueryView: View {
    @Query var tasks: [Task]
    @Binding var taskToEdit: Task?
    
    private var uncompletedTasks: [Task] { tasks.filter { !$0.isCompleted } }
    private var completedTasks: [Task] { tasks.filter { $0.isCompleted } }
    
    init(selectedDate: Date, taskToEdit: Binding<Task?>) {
        self._taskToEdit = taskToEdit
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = #Predicate<Task> { task in
            task.plannedDateEnd >= startOfDay && task.plannedDateStart < endOfDay
        }
        self._tasks = Query(filter: predicate, sort: \.plannedDateStart)
    }
    
    var body: some View {
        if tasks.isEmpty {
            ContentUnavailableView("没有任务", systemImage: "calendar.badge.exclamationmark")
        } else {
            if !uncompletedTasks.isEmpty {
                Section("待办事项") {
                    ForEach(uncompletedTasks) { task in
                        TaskRowView(task: task) { taskToEdit = task }
                    }
                }
            }
            if !completedTasks.isEmpty {
                Section("已完成") {
                    ForEach(completedTasks) { task in
                        TaskRowView(task: task) { taskToEdit = task }
                    }
                }
            }
        }
    }
}
