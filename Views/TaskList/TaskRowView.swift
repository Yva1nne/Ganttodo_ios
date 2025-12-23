import SwiftUI
import SwiftData
import WidgetKit 

struct TaskRowView: View {
    @Environment(\.modelContext) var context
    @Bindable var task: Task
    var onEdit: () -> Void
    
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 12) {
                Rectangle()
                    .fill(task.category?.color ?? .gray.opacity(0.5))
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)
                
                Button(action: {
                    withAnimation {
                        // 1. 改变数据
                        task.isCompleted.toggle()
                        task.completionDate = task.isCompleted ? Date() : nil
                        
                        // 2. 立即保存数据到磁盘
                        try? context.save()
                        
                        // 3. 确认保存后，再通知小组件刷新
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .primary)
                        .imageScale(.large)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    if let note = task.note, !note.isEmpty {
                        Text(note)
                            .font(.system(size: 12)) // 较小字号
                            .foregroundColor(.secondary) // 灰色
                            .lineLimit(2) // 限制显示行数，避免列表过长
                    }
                    
                    Text(formatDateRange(start: task.plannedDateStart, end: task.plannedDateEnd))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let deadline = task.deadline, !task.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                            Text("截止于 \(deadline, formatter: DateFormatter.yyyyMMddHHmm)")
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: onEdit)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let startString = DateFormatter.yyyyMMdd.string(from: start)
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return startString
        } else {
            let endString = DateFormatter.yyyyMMdd.string(from: end)
            return "\(startString) - \(endString)"
        }
    }
}
