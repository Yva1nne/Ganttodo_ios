import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query(sort: \TaskCategory.name) var categories: [TaskCategory]
    
    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    // 点击行进入编辑页面，传入当前 category
                    EditCategoryView(category: category)
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: category.colorHex) ?? .gray)
                            .frame(width: 12, height: 12)
                        Text(category.name)
                    }
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .navigationTitle("分类管理")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: addCategory) {
                    Label("添加", systemImage: "plus")
                }
            }
        }
    }
    
    private func addCategory() {
        // 创建一个新的默认分类
        let newCategory = TaskCategory(name: "新分类", colorHex: "#808080")
        context.insert(newCategory)
        // 插入后，它会自动出现在列表中，用户可以点击进去修改
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            context.delete(category)
        }
    }
}