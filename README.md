# Ganttodo iOS

使用 SwiftUI 构建的本地任务管理原型，以任务列表、日历和桌面小组件呈现跨天计划。

## 已实现功能

- 新建、编辑、删除和完成任务
- 按已过期、今天、即将到来、稍后和已完成分组
- 记录任务计划起止日期、截止日期与类别
- 月历视图与每日任务展示
- 中号 / 大号 Calendar Widget
- 使用 SwiftData 在 App 与 Widget 之间共享本地数据

## 技术栈

- Swift 5
- SwiftUI
- SwiftData
- WidgetKit
- Xcode Project

## 本地运行

1. 使用 Xcode 打开 `Todo.xcodeproj`。
2. 为 `Todo` 和 `CalendarWidgetExtension` 选择自己的 Development Team。
3. 修改两个 target 的 Bundle Identifier。
4. 注册自己的 App Group，并在以下位置使用同一个标识：
   - `Todo/Todo.entitlements`
   - `CalendarWidgetExtension.entitlements`
   - `Todo/TodoApp.swift`
   - `CalendarWidget/CalendarWidget.swift`
5. 选择模拟器或真机，运行 `Todo` scheme。

当前工程配置中，主 App 的 deployment target 为 iOS 18.5，Widget target 为 iOS 26.0。正式运行或分发前应在 Xcode 中将两者调整为同一组经过验证的系统版本；本仓库暂不声明兼容性矩阵。

## 数据模型

```text
TaskCategory
  -> name / color
  -> tasks

Task
  -> title / completed
  -> planned start / planned end / deadline
  -> category / subtasks / parent task
```

App 与 Widget 通过 App Group 中的 `Todo.sqlite` 共用 SwiftData 容器。数据保存在设备本地，当前没有账号、云同步、多人协作、通知提醒或 AI 排期能力。

## 项目结构

```text
Models/                 SwiftData 模型
Views/                  任务列表、编辑与日历界面
ViewModels/             示例任务管理逻辑
CalendarWidget/         WidgetKit 扩展
Todo/                   App 入口与资源
Todo.xcodeproj/         Xcode 工程配置
```

## 当前状态

这是功能原型，不是 App Store 发布版本。签名、App Group、deployment target 和真机兼容性仍需在发布前完成验证；现有单元测试与 UI 测试基本为 Xcode 模板。

本仓库未提供开源许可证；代码与素材默认保留全部权利。
