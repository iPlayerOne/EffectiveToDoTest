import Foundation
import UIKit

protocol TaskEditRouter: AnyObject {
    static func assembleModule(task: TaskListEntity?, repository: TaskRepository, delegate: TaskEditDelegate?) -> UIViewController
    func presentDiscardAlert(onDecision: @escaping (Bool) -> Void)
}

final class TaskEditRouterImpl: TaskEditRouter {
    
    static func assembleModule(task: TaskListEntity?, repository: TaskRepository, delegate: TaskEditDelegate?) -> UIViewController {
        let view = TaskEditViewController()
        let router = TaskEditRouterImpl()
        let interactor = TaskEditInteractorImpl(repository: repository)
        let presenter = TaskEditPresenterImpl(view: view, interactor: interactor, router: router, task: task)
        
        presenter.delegate = delegate
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
    
    func presentDiscardAlert(onDecision: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(
            title: "Отмена изменений",
            message: "Вы уверены, что хотите отменить изменения?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            onDecision(false)
        }
        let confirmAction = UIAlertAction(title: "Подтвердить", style: .default) { _ in
            onDecision(true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        } else {
            onDecision(false)
        }
    }
}
