import SwiftUI
import SwiftData

@main
struct ToDoApp: App {
    let container: ModelContainer = {
        let schema = Schema([Task.self, TaskCategory.self])
        let appGroupID = "group.Yvaine.Todo"
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("Failed to get container URL for app group.")
        }
        let storeURL = containerURL.appendingPathComponent("Todo.sqlite")
        let config = ModelConfiguration(url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}
