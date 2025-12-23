import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \TaskCategory.name) var categories: [TaskCategory]
    
    // 控制新建/编辑弹窗
    @State private var categoryToEdit: TaskCategory?
    @State private var showEditSheet = false
    
    var body: some View {
        List {
            // 1. 现有分类列表
            ForEach(categories) { category in
                HStack {
                    Circle()
                        .fill(Color(hex: category.colorHex) ?? .gray)
                        .frame(width: 12, height: 12)
                    Text(category.name)
                    Spacer()
                    // 编辑按钮
                    Button {
                        categoryToEdit = category
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onDelete(perform: deleteCategories)
            
            // 2. 列表最后一行为新建按钮
            Button(action: {
                categoryToEdit = nil // nil 表示新建
                showEditSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("新建分类")
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("分类管理")
        // 弹窗处理新建或编辑
        .sheet(item: $categoryToEdit) { category in
            CategoryEditSheet(category: category)
        }
        .sheet(isPresented: $showEditSheet) {
            // 当 categoryToEdit 为 nil 且 showEditSheet 为 true 时，新建
            if categoryToEdit == nil {
                CategoryEditSheet(category: nil)
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            context.delete(categories[index])
        }
    }
}

// MARK: - 辅助视图：分类编辑/新建弹窗
struct CategoryEditSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    // 如果传入 nil，则表示新建模式
    var category: TaskCategory?
    
    @State private var name: String = ""
    @State private var color: Color = .blue
    
    var isNew: Bool { category == nil }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("分类名称", text: $name)
                ColorPicker("分类颜色", selection: $color)
            }
            .navigationTitle(isNew ? "新建分类" : "编辑分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let category = category {
                    name = category.name
                    color = Color(hex: category.colorHex) ?? .gray
                }
            }
        }
        .presentationDetents([.height(250)]) // 让弹窗小一点
    }
    
    private func save() {
        if let category = category {
            // 编辑模式
            category.name = name
            category.colorHex = color.toHex()
        } else {
            // 新建模式
            // 注意：这里需要传入 Color 类型，确保 Models/Task.swift 中 TaskCategory init 支持
            let newCategory = TaskCategory(name: name, color: color)
            context.insert(newCategory)
        }
    }
}
