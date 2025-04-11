import Foundation

protocol TaskEditInteractor: AnyObject {
    func createTask(title: String, details: String?)
    func updateTask(id: Int64, title: String, details: String?)
}

final class TaskEditInteractorImpl: TaskEditInteractor {
    weak var presenter: TaskEditPresenter?
    private let repository: TaskRepository
    
    init(repository: TaskRepository) {
        self.repository = repository
    }
    
    func createTask(title: String, details: String?) {
        repository.createTask(title: title, details: details, date: Date()) {[weak self] result in
            switch result {
                case .success:
                    self?.presenter?.didFinishSaving()
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
            }
        }
    }
    
    func updateTask(id: Int64, title: String, details: String?) {
        repository.updateTask(
            taskId: id,
            newTitle: title,
            newDecription: details,
            newDate: nil,
            newCompleted: nil
        ) { [weak self] result in
            switch result {
                case .success:
                    self?.presenter?.didFinishSaving()
                case .failure(let error):
                    self?.presenter?.didFail(with: error)
            }
        }
    }
    
    
}
