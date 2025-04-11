import Foundation

protocol TaskListInteractor: AnyObject {
    func fetchTasks()
    func searchTasks(with query: String)
    func toggleTask(taskId: Int64, newCompleted: Bool)
    func deleteTask(taskId: Int64)
    
}

final class TaskListInteractorImpl: TaskListInteractor {
    weak var presenter: TaskListPresenter?
    private let repository: TaskRepository
    private let launchManager: LaunchManager
    
    init(repository: TaskRepository, launchManager: LaunchManager) {
        self.repository = repository
        self.launchManager = launchManager
    }
    
    
    func fetchTasks() {
        if launchManager.isFirstLaunch {
            refreshData()
        } else {
            fetchLocal()
        }
    }
    
    func searchTasks(with query: String) {
        repository.searchTasks(query: query) { [weak self] result in
            switch result {
                case .success(let tasks):
                    self?.presenter?.didLoad(tasks: tasks)
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
            }
        }
    }
    
    func toggleTask(taskId: Int64, newCompleted: Bool) {
        repository.updateTask(
            taskId: taskId,
            newTitle: nil,
            newDecription: nil,
            newDate: nil,
            newCompleted: newCompleted) { [weak self] result in
                switch result {
                    case .success:
                        self?.fetchLocal()
                    case .failure(let error):
                        self?.presenter?.didFail(with: error)
                }
            }
    }
    
    func deleteTask(taskId: Int64) {
        repository.deleteTask(taskId: taskId) { [weak self] result in
            switch result {
                case .success:
                    self?.fetchLocal()
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
            }
        }
    }
    
    private func refreshData() {
        repository.fetchRemoteTodos { [weak self] result in
            switch result {
                case .success(let todos):
                    self?.repository.saveTasks(todos) { saveResult in
                        switch saveResult {
                            case .success:
                                self?.launchManager.markAppLaunched()
                                self?.fetchLocal()
                            case .failure(let error):
                                self?.presenter?.didFail(with: error)
                        }
                        
                    }
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
            }
        }
    }
    
    private func clearAndRefresh() {
        repository.clearLocalTasks { [weak self] clearResult in
            switch clearResult {
                case .success:
                    self?.refreshData()
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
            }
        }
    }
    
    private func fetchLocal() {
        repository.fetchLocalTodos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tasks):
                    self?.presenter?.didLoad(tasks: tasks)
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
                }
            }
        }
    }
    
    
}
