import SwiftUI
import SwiftData
import WidgetKit

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var task: Task
    
    @Query(sort: \TaskCategory.name) var categories: [TaskCategory]
    
    @State private var title: String
    @State private var isCompleted: Bool
    @State private var completionDate: Date?
    @State private var plannedDateStart: Date
    @State private var plannedDateEnd: Date
    @State private var deadline: Date?
    @State private var category: TaskCategory?
    @State private var hasDeadline: Bool = false
    
    @State private var isCreatingCategory = false
    @State private var newCategoryName: String = ""
    @State private var newCategoryColor: Color = .red

    @State private var categoryToEdit: TaskCategory?

    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _isCompleted = State(initialValue: task.isCompleted)
        _completionDate = State(initialValue: task.completionDate)
        _plannedDateStart = State(initialValue: task.plannedDateStart)
        _plannedDateEnd = State(initialValue: task.plannedDateEnd)
        _deadline = State(initialValue: task.deadline)
        _category = State(initialValue: task.category)
        _hasDeadline = State(initialValue: task.deadline != nil)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任务详情")) { TextField("任务名称", text: $title) }
                
                Section(header: Text("时间安排")) {
                    DatePicker("计划开始", selection: $plannedDateStart, displayedComponents: .date)
                    DatePicker("计划完成", selection: $plannedDateEnd, displayedComponents: .date)
                    
                    Toggle(isOn: $hasDeadline.animation()) { Text("设置截止日期") }
                    if hasDeadline {
                        DatePicker("截止于", selection: Binding(get: { deadline ?? Date() }, set: { deadline = $0 }))
                    }
                }
                
                Section(header: Text("分类")) {
                    HStack {
                        Text("选择分类")
                        Spacer()
                        Menu {
                            Button(action: { self.category = nil }) { Text("无") }
                            ForEach(categories) { cat in
                                Button(action: { self.category = cat }) {
                                    Label(cat.name, systemImage: "circle.fill")
                                        .tint(cat.color)
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if let category = category {
                                    Circle().fill(category.color).frame(width: 16, height: 16)
                                    Text(category.name)
                                } else {
                                    Text("无")
                                }
                                Image(systemName: "chevron.up.chevron.down").font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    if isCreatingCategory {
                        HStack {
                            TextField("新分类名称", text: $newCategoryName)
                            ColorPicker("", selection: $newCategoryColor)
                        }
                        Button("添加并选择") { addAndSelectCategory() }.disabled(newCategoryName.isEmpty)
                    }
                    
                    Button(isCreatingCategory ? "取消" : "新建分类") {
                        withAnimation { isCreatingCategory.toggle() }
                    }
                    
                    Button("编辑所选分类") {
                        if let selectedCategory = self.category {
                            self.categoryToEdit = selectedCategory
                        }
                    }
                    .disabled(category == nil)
                }
                
                //
                // MARK: - Request 1: "Status" section moved and simplified
                //
                Section(header: Text("状态")) {
                    Toggle(isOn: $isCompleted.animation()) {
                        Text("已完成")
                    }
                    
                    if isCompleted {
                        // DatePicker now only shows date component
                        DatePicker("完成于", selection: Binding(get: {
                            completionDate ?? Date()
                        }, set: { newDate in
                            completionDate = newDate
                        }), displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(task.title.isEmpty ? "新建任务" : "编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveAndDismiss() }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(item: $categoryToEdit) { category in EditCategoryView(category: category) }
            .onChange(of: plannedDateStart) {
                if plannedDateStart > plannedDateEnd {
                    plannedDateEnd = plannedDateStart
                }
            }
            .onChange(of: isCompleted) {
                if isCompleted {
                    if completionDate == nil {
                        completionDate = Date()
                    }
                } else {
                    completionDate = nil
                }
            }
        }
    }
    
    private func addAndSelectCategory() {
        let newCategory = TaskCategory(name: newCategoryName, color: newCategoryColor)
        context.insert(newCategory)
        try? context.save()
        self.category = newCategory
        newCategoryName = ""
        withAnimation { isCreatingCategory = false }
    }
    
    private func saveAndDismiss() {
        // 1. 改变数据
        task.title = title
        task.isCompleted = isCompleted
        if let completionDate = completionDate {
            task.completionDate = Calendar.current.startOfDay(for: completionDate)
        } else {
            task.completionDate = nil
        }
        task.plannedDateStart = Calendar.current.startOfDay(for: plannedDateStart)
        task.plannedDateEnd = Calendar.current.startOfDay(for: plannedDateEnd)
        task.category = category
        task.deadline = hasDeadline ? deadline : nil
        
        if task.modelContext == nil {
            context.insert(task)
        }
        
        // 2. 立即保存数据到磁盘
        try? context.save()
        
        // 3. 确认保存后，再通知小组件刷新
        WidgetCenter.shared.reloadAllTimelines()
        
        dismiss()
    }
}
