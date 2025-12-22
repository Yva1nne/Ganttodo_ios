//
//  TaskManager.swift
//  Todo
//
//  Created by Yvaine on 2025/9/15.
//

import SwiftUI
import Combine

// 使用 ObservableObject 使其能够被 SwiftUI 视图监听
class TaskManager: ObservableObject {
    
    // @Published 会在数据变化时自动通知所有监听的视图进行刷新
    @Published var tasks: [Task] = []
    @Published var categories: [TaskCategory] = []
    
    init() {
        // 在初始化时加载示例数据
        loadSampleData()
    }
    
    // MARK: - Sample Data
    func loadSampleData() {
        // 1. 创建示例类别
        let workCategory = TaskCategory(name: "工作", color: .blue)
        let personalCategory = TaskCategory(name: "个人", color: .green)
        let studyCategory = TaskCategory(name: "学习", color: .orange)
        self.categories = [workCategory, personalCategory, studyCategory]
        
        // 2. 创建示例任务
        let today = Date()
        let calendar = Calendar.current
        
        var sampleTasks: [Task] = [
            Task(title: "完成 SwiftUI 项目设计稿", plannedDateStart: today, plannedDateEnd: today, deadline: calendar.date(byAdding: .day, value: 1, to: today)!, category: workCategory),
            Task(title: "健身：胸部训练", isCompleted: true, plannedDateStart: calendar.date(byAdding: .day, value: -1, to: today)!, plannedDateEnd: calendar.date(byAdding: .day, value: -1, to: today)!, category: personalCategory),
            Task(title: "准备周五的会议材料", plannedDateStart: calendar.date(byAdding: .day, value: 2, to: today)!, plannedDateEnd: calendar.date(byAdding: .day, value: 4, to: today)!, category: workCategory),
            Task(title: "阅读《原子习惯》第三章", plannedDateStart: today, plannedDateEnd: today, category: studyCategory, subtasks: [
                Task(title: "子任务：阅读前10页", plannedDateStart: today, plannedDateEnd: today, category: studyCategory),
                Task(title: "子任务：做笔记", isCompleted: true, plannedDateStart: today, plannedDateEnd: today, category: studyCategory)
            ]),
            Task(title: "缴纳水电费", plannedDateStart: calendar.date(byAdding: .day, value: 6, to: today)!, plannedDateEnd: calendar.date(byAdding: .day, value: 6, to: today)!, deadline: calendar.date(byAdding: .day, value: 10, to: today)!, category: personalCategory),
             Task(title: "预定下个月的机票", plannedDateStart: calendar.date(byAdding: .month, value: 1, to: today)!, plannedDateEnd: calendar.date(byAdding: .month, value: 1, to: today)!, category: personalCategory)
        ]
        
        // 按照计划开始时间排序
        self.tasks = sampleTasks.sorted { $0.plannedDateStart < $1.plannedDateStart }
    }
    
    // MARK: - Dashboard Logic
    // 计算属性，用于看板视图
    
    var todayTasks: [Task] {
        tasks.filter { task in
            let isPlannedForToday = Calendar.current.isDateInToday(task.plannedDateStart) || Calendar.current.isDateInToday(task.plannedDateEnd)
            let isDeadlineToday = task.deadline != nil && Calendar.current.isDateInToday(task.deadline!)
            return !task.isCompleted && (isPlannedForToday || isDeadlineToday)
        }
    }
    
    var upcomingTasks: [Task] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        return tasks.filter { task in
            return !task.isCompleted && (task.plannedDateStart >= tomorrow && task.plannedDateStart <= nextWeek)
        }
    }
    
    var laterTasks: [Task] {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 8, to: Date())!
        
        return tasks.filter { task in
            return !task.isCompleted && task.plannedDateStart >= nextWeek
        }
    }
    
    // MARK: - CRUD (Create, Read, Update, Delete)
    // 后续可以在这里添加创建、更新、删除任务的函数
    
    func toggleCompletion(for task: Task) {
        // 这是一个简化的示例，在实际应用中需要更复杂的逻辑来查找和更新嵌套任务
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
