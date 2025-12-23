import SwiftUI
import SwiftData
import WidgetKit

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var task: Task
    
    @Query(sort: \TaskCategory.name) var categories: [TaskCategory]
    
    // 状态变量
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var note: String = ""
    
    @State private var plannedDateStart: Date = Date()
    @State private var plannedDateEnd: Date = Date()
    
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Date()
    
    @State private var category: TaskCategory?
    @State private var showCategorySheet = false // 控制分类选择弹窗
    
    @State private var isCompleted: Bool = false
    @State private var completionDate: Date = Date()
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _location = State(initialValue: task.location ?? "")
        _note = State(initialValue: task.note ?? "")
        
        _plannedDateStart = State(initialValue: task.plannedDateStart)
        _plannedDateEnd = State(initialValue: task.plannedDateEnd)
        
        _hasDeadline = State(initialValue: task.deadline != nil)
        _deadline = State(initialValue: task.deadline ?? Date())
        
        _category = State(initialValue: task.category)
        
        _isCompleted = State(initialValue: task.isCompleted)
        _completionDate = State(initialValue: task.completionDate ?? Date())
    }

    var body: some View {
        NavigationView {
            Form {
                // 1. 任务详情
                Section(header: Text("任务详情")) {
                    TextField("任务名称", text: $title)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                        TextField("地点", text: $location)
                    }
                }
                
                // 2. 时间安排
                Section(header: Text("时间安排")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("开始").font(.caption).foregroundColor(.secondary)
                            DatePicker("", selection: $plannedDateStart, displayedComponents: [.date]).labelsHidden()
                        }
                        Spacer()
                        Image(systemName: "arrow.right").foregroundColor(.secondary).font(.caption)
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("完成").font(.caption).foregroundColor(.secondary)
                            DatePicker("", selection: $plannedDateEnd, displayedComponents: [.date]).labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Toggle("设置截止日期", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("截止时间", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                // 3. 分类 (还原为点击弹出选择)
                Section(header: Text("分类")) {
                    Button(action: { showCategorySheet = true }) {
                        HStack {
                            Text("选择分类").foregroundColor(.primary)
                            Spacer()
                            if let category = category {
                                Circle().fill(Color(hex: category.colorHex) ?? .gray).frame(width: 10, height: 10)
                                Text(category.name).foregroundColor(.secondary)
                            } else {
                                Text("无").foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.up.chevron.down") // 换成上下箭头，暗示选择
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 4. 备注
                Section(header: Text("备注")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if note.isEmpty {
                                    Text("添加备注...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                        .allowsHitTesting(false)
                                }
                            }
                        )
                }
                
                // 5. 状态
                Section(header: Text("状态")) {
                    Toggle("已完成", isOn: $isCompleted)
                    if isCompleted {
                        DatePicker("完成日期", selection: $completionDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                if task.modelContext != nil {
                    Section {
                        Button(role: .destructive) { deleteTask() } label: {
                            HStack { Spacer(); Text("删除任务"); Spacer() }
                        }
                    }
                }
            }
            .navigationTitle(task.modelContext == nil ? "新建任务" : "编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { saveAndDismiss() }.disabled(title.isEmpty) }
            }
            // 分类选择 Sheet (简洁版)
            .sheet(isPresented: $showCategorySheet) {
                NavigationView {
                    List {
                        // 1. 无分类选项
                        Button {
                            category = nil
                            showCategorySheet = false
                        } label: {
                            HStack {
                                Text("无").foregroundColor(.primary)
                                Spacer()
                                if category == nil {
                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // 2. 现有分类列表
                        ForEach(categories) { cat in
                            Button {
                                category = cat
                                showCategorySheet = false
                            } label: {
                                HStack {
                                    Circle().fill(Color(hex: cat.colorHex) ?? .gray).frame(width: 12, height: 12)
                                    Text(cat.name).foregroundColor(.primary)
                                    Spacer()
                                    if category == cat {
                                        Image(systemName: "checkmark").foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("选择分类")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            // 快捷入口：去管理分类 (如果用户想在选择时新建)
                            NavigationLink(destination: CategoryManagementView()) {
                                Text("管理")
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func saveAndDismiss() {
        task.title = title
        task.location = location
        task.note = note
        task.plannedDateStart = Calendar.current.startOfDay(for: plannedDateStart)
        task.plannedDateEnd = Calendar.current.startOfDay(for: plannedDateEnd)
        task.deadline = hasDeadline ? deadline : nil
        task.category = category
        task.isCompleted = isCompleted
        task.completionDate = isCompleted ? completionDate : nil
        
        if task.modelContext == nil { context.insert(task) }
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
    
    private func deleteTask() {
        if let context = task.modelContext {
            context.delete(task)
            try? context.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
        dismiss()
    }
}
