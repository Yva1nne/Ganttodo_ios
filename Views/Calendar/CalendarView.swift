import SwiftUI
import SwiftData

struct CalendarView: View {
    var tasks: [Task]
    @State private var currentDate = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                weekdayHeader
                
                ScrollView {
                    CalendarWeekLayoutView(currentDate: $currentDate, tasks: tasks)
                }
            }
            .padding(.horizontal)
            .navigationTitle("日历视图")
            .navigationBarHidden(true)
        }
    }
    private var headerView: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left").contentShape(Rectangle()) }
            Spacer()
            Text(currentDate, formatter: monthYearFormatter).font(.title).fontWeight(.bold)
            Spacer()
            Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right").contentShape(Rectangle()) }
        }
        .padding(.vertical)
    }
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol).font(.caption).frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 5)
    }
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY年 M月"
        return formatter
    }
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: currentDate) {
            currentDate = newDate
        }
    }
}

struct CalendarWeekLayoutView: View {
    @Binding var currentDate: Date
    var tasks: [Task]
    
    //
    // MARK: - 使用新的统一日期生成器
    //
    private var weeks: [[Date]] {
        Calendar.current.generateDates(for: currentDate)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(weeks, id: \.self) { week in
                // isInteractive 默认为 true
                WeekView(week: week, tasks: tasks, currentDate: currentDate)
            }
        }
    }
}

