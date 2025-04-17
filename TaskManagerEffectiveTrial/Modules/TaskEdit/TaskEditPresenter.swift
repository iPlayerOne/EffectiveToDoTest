import Foundation

protocol TaskEditPresenter: AnyObject {
    func viewDidLoad()
    func didTapBack(title: String?, details: String?)
    func didFinishSaving()
    func didFail(with error: Error)
}

protocol TaskEditDelegate: AnyObject {
    func didFinishEditingTask()
}

final class TaskEditPresenterImpl: TaskEditPresenter {
    weak var delegate: TaskEditDelegate?
    
    private weak var view: TaskEditView?
    private let interactor: TaskEditInteractor
    private let router: TaskEditRouter
    private let task: TaskListEntity?
    
    init(view: TaskEditView,
         interactor: TaskEditInteractor,
         router: TaskEditRouter,
         task: TaskListEntity?) {
        
        self.view = view
        self.interactor = interactor
        self.router = router
        self.task = task
    }
    
    func viewDidLoad() {
        view?.showTask(task)
    }
    
    func didTapBack(title: String?, details: String?) {
        let title = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let details = details?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard validate(title, details) else { return }
        
        if let task = task {
            interactor.updateTask(id: task.id, title: title, details: details)
        } else {
            interactor.createTask(title: title, details: details)
        }
    }
    
    func didFinishSaving() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let view = self.view else { return }
            self.delegate?.didFinishEditingTask()
            self.router.close(from: view)
        }
    }
    
    func didFail(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showError(error.localizedDescription)
        }
    }
    
    private func validate(_ title: String, _ details: String) -> Bool {
        if title.isEmpty && details.isEmpty {
            if let view = view { router.close(from: view) }
            return false
        }
        
        guard !title.isEmpty else {
            view?.showError("Заголовок зачем-то не может быть пустым 🤷‍♂️")
            return false
        }
        return true
    }
}

extension TaskListPresenterImpl: TaskEditDelegate {
    func didFinishEditingTask() {
        view?.showLoading()
        interactor.fetchTasks()
    }
}
