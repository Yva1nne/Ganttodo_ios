//
//  EditCategoryView.swift
//  Todo
//
//  Created by Yvaine on 2025/9/16.
//


import SwiftUI
import SwiftData

struct EditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    
    // 使用 @Bindable，这样对分类的修改会通过 SwiftData 自动保存
    @Bindable var category: TaskCategory

    // ColorPicker 需要绑定到一个 Color 类型，
    // 但我们的模型存储的是十六进制字符串。
    // 这个计算属性创建了一个中间绑定，用于在 Color 和 String 之间转换。
    private var categoryColorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: category.colorHex) ?? .clear },
            set: { newColor in category.colorHex = newColor.toHex() }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section("分类名称") {
                    TextField("名称", text: $category.name)
                }
                
                Section("分类颜色") {
                    ColorPicker("选择颜色", selection: categoryColorBinding)
                }
            }
            .navigationTitle("编辑分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}