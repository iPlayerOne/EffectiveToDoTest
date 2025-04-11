import UIKit

enum TaskContextMenuFactory {
    static func makeMenu(
        for task: TaskListEntity,
        presenter: TaskListPresenter?,
        presenterVC: UIViewController
    ) -> UIMenu {
        let editAction = UIAction(title: "Редактировать", image: UIImage(named: "iconEdit")) { _ in
            presenter?.didTapEdit(for: task)
        }
        
        let shareAction = UIAction(title: "Поделиться", image: UIImage(named: "iconShare")) { _ in
            let textToShare = "\(task.title)\n\n\(task.details)"
            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            activityVC.overrideUserInterfaceStyle = .light
            
            presenterVC.present(activityVC, animated: true)
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(named: "iconDelete")) { _ in
            presenter?.deleteTask(withId: task.id )
        }
        
        return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
    }
}
