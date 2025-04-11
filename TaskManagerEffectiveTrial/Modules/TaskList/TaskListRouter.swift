import Foundation
import UIKit

protocol TaskListRouter: AnyObject {
    static func assembleModule(repository: TaskRepository, launchManager: LaunchManager, appDependency: AppDependency, navigationController: UINavigationController) -> UIViewController
    func presentTaskEdit(from view: TaskListView, task: TaskListEntity?, delegate: TaskEditDelegate?)
}

final class TaskListRouterImpl: TaskListRouter {
    weak var navigationController: UINavigationController?
    private let dependencies: AppDependency
    
    init(navigationController: UINavigationController?, appDependency: AppDependency) {
        self.navigationController = navigationController
        self.dependencies = appDependency
    }
    
    static func assembleModule(repository: TaskRepository, launchManager: LaunchManager, appDependency: AppDependency, navigationController: UINavigationController) -> UIViewController {
        let view = TaskListViewController()
        let interactor = TaskListInteractorImpl(repository: repository, launchManager: launchManager)
        let router = TaskListRouterImpl(navigationController: navigationController, appDependency: appDependency)
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
    
    func presentTaskEdit(from view:TaskListView, task: TaskListEntity?, delegate: TaskEditDelegate?) {
        let controller = TaskEditRouterImpl.assembleModule(task: task, repository: dependencies.toDoRepository, delegate: delegate)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
