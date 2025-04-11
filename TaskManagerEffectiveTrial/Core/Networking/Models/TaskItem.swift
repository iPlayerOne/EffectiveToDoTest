import Foundation

struct TaskResponse: Decodable {
    let todos: [TaskItem]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TaskItem: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
