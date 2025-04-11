import Foundation
import CoreData

extension TaskEntity {
    func toDTO() -> TaskListEntity {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let dateString = self.createdAt.map { formatter.string(from: $0) } ?? ""
        let detailsText = self.details ?? ""
        return TaskListEntity(
            id: self.id,
            title: self.title ?? "",
            details: detailsText,
            date: dateString,
            isCompleted: self.isCompleted
            )
    }
}
