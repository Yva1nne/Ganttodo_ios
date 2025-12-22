//
//  ______.swift
//  月视图小组件
//
//  Created by Yvaine on 2025/9/21.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    let modelContainer: ModelContainer
    init(modelContainer: ModelContainer) { self.modelContainer = modelContainer }
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date(), tasks: [], family: context.family) }
    
    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.isCompleted == false
            }
        )
        let tasks = (try? modelContainer.mainContext.fetch(descriptor)) ?? []
        let entry = SimpleEntry(date: Date(), tasks: tasks, family: context.family)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.isCompleted == false
            }
        )
        let tasks = (try? modelContainer.mainContext.fetch(descriptor)) ?? []
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, tasks: tasks, family: context.family)
        
        // 1. 计算一小时后的时间
        let oneHourLater = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        // 2. 计算下一个午夜零点的时间
        let startOfTomorrow = Calendar.current.nextDate(after: currentDate, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime)!
        
        // 3. 取两者中较早的那个时间作为下一次刷新时间
        let nextUpdateDate = min(oneHourLater, startOfTomorrow)
        
        // 4. 创建时间线，让小组件在 nextUpdateDate 时刷新
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [Task]
    // Pass the widget family to the entry
    let family: WidgetFamily
}

// MARK: - The Widget's View
struct CalendarWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        // Use the new, dedicated widget view
        WidgetCalendarView(tasks: entry.tasks, monthDate: entry.date, family: entry.family)
    }
}

// MARK: - The Main Widget Definition
@main
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Task.self, TaskCategory.self])
        let appGroupID = "group.Yvaine.Todo" // 确认这是您的 ID
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("Failed to get container URL for app group.")
        }
        let storeURL = containerURL.appendingPathComponent("Todo.sqlite")
        let config = ModelConfiguration(url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create model container for widget: \(error)")
        }
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(modelContainer: sharedModelContainer)) { entry in
            CalendarWidgetEntryView(entry: entry)
                .modelContainer(sharedModelContainer)
                .containerBackground(for: .widget) {
                    Color(.systemBackground)
                }
        }
        .configurationDisplayName("月视图")
        .description("在主屏幕上查看您的任务日历。")
        //
        // MARK: - 最终修复：同时支持中尺寸和大尺寸
        //
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
