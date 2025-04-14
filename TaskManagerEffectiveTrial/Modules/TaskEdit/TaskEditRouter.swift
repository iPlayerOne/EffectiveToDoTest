import Foundation
import UIKit

protocol TaskEditRouter: AnyObject {
    static func assembleModule(task: TaskListEntity?, repository: TaskRepository, delegate: TaskEditDelegate?) -> UIViewController
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
}
