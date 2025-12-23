//
//  SettingsView.swift
//  Todo
//
//  Created by Yvaine on 2025/12/23.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: CategoryManagementView()) {
                        Label("分类管理", systemImage: "tag")
                    }
                } header: {
                    Text("常规")
                }
                
                // 这里预留位置给后续的其他设置 (如: 外观、通知等)
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("v2.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}