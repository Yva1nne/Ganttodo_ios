import SwiftUI
import SwiftData

@Model
final class TaskCategory: Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    
    @Relationship(deleteRule: .cascade, inverse: \Task.category)
    var tasks: [Task]?
    
    init(name: String, color: Color) {
        self.id = UUID()
        self.name = name
        self.colorHex = color.toHex()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    static func == (lhs: TaskCategory, rhs: TaskCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
final class Task: Hashable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    
    var plannedDateStart: Date
    var plannedDateEnd: Date
    
    var deadline: Date?
    var completionDate: Date?
    
    var category: TaskCategory?
    
    @Relationship(deleteRule: .cascade)
    var subtasks: [Task]?
    var parentTask: Task?
    
    init(title: String,
         isCompleted: Bool = false,
         plannedDateStart: Date = Date(),
         plannedDateEnd: Date = Date(),
         deadline: Date? = nil,
         completionDate: Date? = nil,
         category: TaskCategory? = nil,
         subtasks: [Task]? = [],
         parentTask: Task? = nil)
    {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.plannedDateStart = plannedDateStart
        self.plannedDateEnd = plannedDateEnd
        self.deadline = deadline
        self.completionDate = completionDate
        self.category = category
        self.subtasks = subtasks
        self.parentTask = parentTask
    }

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
