import SwiftUI

struct WeekView: View {
    let week: [Date]
    let tasks: [Task]
    let currentDate: Date // Represents the month being viewed
    
    var isInteractive: Bool = true // Default to true for App use
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter(); formatter.dateFormat = "d"; return formatter
    }
    
    // Function to arrange tasks into non-overlapping rows
    private func arrangeTasksIntoRows() -> [[Task]] {
        guard let firstDay = week.first, let lastDay = week.last else { return [] }
        let calendar = Calendar.current
        
        let weekStart = calendar.startOfDay(for: firstDay)
        // Correctly calculate the end of the week interval (start of the day *after* the last day)
        let weekEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastDay))!
        
        //
        // MARK: - Final Robust Task Filtering Logic
        //
        let tasksInWeek = tasks.filter { task in
            let taskStart = calendar.startOfDay(for: task.plannedDateStart)
            let effectiveEnd = max(task.plannedDateStart, task.plannedDateEnd)
            let taskEnd = calendar.startOfDay(for: effectiveEnd) // Use the actual end day

            // A task intersects the week if:
            // Task's start is *before* the week ends (exclusive end)
            // AND Task's end is *on or after* the week starts (inclusive start)
            return taskStart < weekEnd && taskEnd >= weekStart
        }
        
        // Separate and sort tasks by completion status
        let uncompleted = tasksInWeek.filter { !$0.isCompleted }.sorted(by: { $0.plannedDateStart < $1.plannedDateStart })
        let completed = tasksInWeek.filter { $0.isCompleted }.sorted(by: { $0.plannedDateStart < $1.plannedDateStart })

        var uncompletedRows: [[Task]] = []
        var completedRows: [[Task]] = []
        
        // Helper to place tasks into rows, avoiding overlaps based on day ranges
        func placeTasks(_ tasksToPlace: [Task], into rows: inout [[Task]]) {
            for task in tasksToPlace {
                var placed = false
                for (rowIndex, row) in rows.enumerated() {
                    if !row.contains(where: { existingTask in
                        let taskStartDay = calendar.startOfDay(for: task.plannedDateStart)
                        let taskEndDay = calendar.startOfDay(for: max(task.plannedDateStart, task.plannedDateEnd))
                        let existingStartDay = calendar.startOfDay(for: existingTask.plannedDateStart)
                        let existingEndDay = calendar.startOfDay(for: max(existingTask.plannedDateStart, existingTask.plannedDateEnd))
                        
                        // Precise overlap check for day ranges
                        return existingStartDay <= taskEndDay && taskStartDay <= existingEndDay
                    }) {
                        rows[rowIndex].append(task); placed = true; break
                    }
                }
                if !placed { rows.append([task]) }
            }
        }
        
        placeTasks(uncompleted, into: &uncompletedRows)
        placeTasks(completed, into: &completedRows)
        
        // Combine rows, uncompleted first
        return uncompletedRows + completedRows
    }

    var body: some View {
        // The rest of the body remains unchanged from the previous correct version
        let arrangedTaskRows = arrangeTasksIntoRows()
        let weekHeight: CGFloat = 22 + (CGFloat(arrangedTaskRows.count) * 20)
        let calendar = Calendar.current

        GeometryReader { geometry in
            let dayWidth = geometry.size.width / 7
            
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { day in
                        if isInteractive {
                            NavigationLink(destination: DailyTaskListView(selectedDate: day)) {
                                dayCellContent(for: day, calendar: calendar, geometry: geometry)
                            }
                            .frame(width: dayWidth, height: weekHeight)
                        } else {
                            dayCellContent(for: day, calendar: calendar, geometry: geometry)
                                .frame(width: dayWidth, height: weekHeight)
                        }
                    }
                }
                
                ForEach(Array(arrangedTaskRows.enumerated()), id: \.offset) { rowIndex, row in
                    ForEach(row) { task in
                        let clippedStart = max(task.plannedDateStart, week.first!)
                        let effectiveTaskEnd = max(task.plannedDateStart, task.plannedDateEnd)
                        let clippedEnd = min(effectiveTaskEnd, week.last!)
                        let startIndex = week.firstIndex(where: { calendar.isDate($0, inSameDayAs: clippedStart) }) ?? 0
                        let endIndex = week.firstIndex(where: { calendar.isDate($0, inSameDayAs: clippedEnd) }) ?? 6
                        let duration = (endIndex - startIndex) + 1
                        let xOffset = CGFloat(startIndex) * dayWidth
                        let barWidth = max(0, CGFloat(duration) * dayWidth - 2)
                        let yOffset = 20 + CGFloat(rowIndex) * 20
                        if barWidth > 0 {
                            TaskBarView(task: task).frame(width: barWidth).offset(x: xOffset + 1, y: yOffset)
                        }
                    }
                }
            }
        }
        .frame(height: weekHeight)
    }
    
    // Day cell content view remains the same
    private func dayCellContent(for day: Date, calendar: Calendar, geometry: GeometryProxy) -> some View {
        VStack {
            Text(dayFormatter.string(from: day))
                .font(.system(size: 10))
                .padding(4)
                .foregroundColor(
                    calendar.isDateInToday(day) ? .red
                    : calendar.isDate(day, equalTo: currentDate, toGranularity: .month) ? .primary
                    : .secondary
                )
                .fontWeight(calendar.isDateInToday(day) ? .bold : .regular)
            Spacer()
        }
        .frame(width: geometry.size.width / 7)
        .border(Color.gray.opacity(0.1), width: 0.5)
    }
}

// TaskBarView remains the same
struct TaskBarView: View {
    var task: Task
    var body: some View {
        Text(task.title)
            .font(.system(size: 10))
            .strikethrough(task.isCompleted, color: .white)
            .foregroundColor(.white)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 4)
            .background(task.category?.color ?? .gray)
            .opacity(task.isCompleted ? 0.6 : 1.0)
            .clipShape(Capsule())
    }
}
