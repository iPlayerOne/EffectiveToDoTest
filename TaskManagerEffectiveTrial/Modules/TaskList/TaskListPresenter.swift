import Foundation

protocol TaskListPresenter: AnyObject {
    func viewDidLoad()
    func didLoad(tasks: [TaskListEntity])
    func didFail(with error: Error)
    func didUpdateSearchQuery(_ query: String)
    func toggleTaskCompletion(for task: TaskListEntity)
    func didTapCreate()
    func didTapEdit(for task: TaskListEntity)
    func deleteTask(withId id: Int64)
    
}

final class TaskListPresenterImpl: TaskListPresenter {
    weak var view: TaskListView?
    let interactor: TaskListInteractor
    let router: TaskListRouter
    
    init(view: TaskListView,
         interactor: TaskListInteractor,
         router: TaskListRouter
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        view?.showLoading()
        interactor.fetchTasks()
    }
    
    func didLoad(tasks: [TaskListEntity]) {
        view?.hideLoading()
        view?.showTasks(tasks)
    }
    
    func didFail(with error:Error) {
        view?.hideLoading()
        view?.showError(error.localizedDescription)
    }
    
    func didUpdateSearchQuery(_ query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
               interactor.fetchTasks()
           } else {
               interactor.searchTasks(with: query)
           }
    }
    
    func toggleTaskCompletion(for task: TaskListEntity) {
        interactor.toggleTask(taskId: task.id, newCompleted: !task.isCompleted)
    }
    
    func didTapCreate() {
        guard let view = view else { return }
        router.presentTaskEdit(from: view, task: nil, delegate: self)
    }
    
    func didTapEdit(for task: TaskListEntity) {
        guard let view = view else { return }
        router.presentTaskEdit(from: view, task: task, delegate: self)
    }
    
    func deleteTask(withId id: Int64) {
        view?.showLoading()
        interactor.deleteTask(taskId: id)
    }
    

}
