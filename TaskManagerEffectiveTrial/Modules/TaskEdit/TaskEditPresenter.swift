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
    weak var view: TaskEditView?
    weak var delegate: TaskEditDelegate?
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
        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedDescription = details?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if trimmedTitle.isEmpty && trimmedDescription.isEmpty {
            view?.close()
            return
        }

        if trimmedTitle.isEmpty {
            view?.showError("Заголовок зачем-то не может быть пустым 🤷‍♂️")
            return
        }

        if let task = task {
            interactor.updateTask(id: task.id, title: trimmedTitle, details: trimmedDescription)
        } else {
            interactor.createTask(title: trimmedTitle, details: trimmedDescription)
        }
    }
    
//    func didTapBack(title: String?, description: String?) {
//        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        let trimmedDescription = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        
//        if trimmedTitle.isEmpty && trimmedDescription.isEmpty {
//            view?.close()
//            return
//        }
//        
//        if let task = task {
//            // Режим редактирования
//            if trimmedTitle.isEmpty {
//                router.presentDiscardAlert { [weak self] confirmed in
//                    if confirmed {
//                        self?.view?.close()
//                    }
//                }
//                return
//            } else {
//                interactor.updateTask(id: task.id, title: trimmedTitle, description: trimmedDescription)
//            }
//        } else {
//            // Режим создания новой задачи
//            if trimmedTitle.isEmpty {
//                view?.showError("Заголовок зачем-то не может быть пустым 🤷‍♂️")
//                return
//            } else {
//                interactor.createTask(title: trimmedTitle, description: trimmedDescription)
//            }
//        }
//    }
    
    func didFinishSaving() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didFinishEditingTask()
            self?.view?.close()
        }
    }
    
    func didFail(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showError(error.localizedDescription)
        }
    }
}

extension TaskListPresenterImpl: TaskEditDelegate {
    func didFinishEditingTask() {
        view?.showLoading()
        interactor.fetchTasks()
    }
}
