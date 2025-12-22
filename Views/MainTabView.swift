import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query(sort: \Task.plannedDateStart) var tasks: [Task]
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Label("任务列表", systemImage: "list.bullet.clipboard.fill")
                }
            
            CalendarView(tasks: tasks)
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Task.self, TaskCategory.self, configurations: config)
        return MainTabView().modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
