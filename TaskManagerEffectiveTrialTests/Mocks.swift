import Foundation
import UIKit
import XCTest
@testable import EffectiveToDoTest

// MARK: - Мок для ToDoRepository

final class MockToDoRepository: TaskRepository {
    var fetchRemoteTodosResult: Result<[TaskItem], Error>?
    var saveTodosResult: Result<Void, Error>?
    var fetchLocalTodosResult: Result<[TaskListEntity], Error>?
    var searchTodosResult: Result<[TaskListEntity], Error>?
    var clearLocalTodosResult: Result<Void, Error>?
    var createTaskResult: Result<Void, Error>?
    var updateTaskResult: Result<Void, Error>?
    var deleteTaskResult: Result<Void, Error>?
    
    func fetchRemoteTodos(completion: @escaping (Result<[TaskItem], Error>) -> Void) {
        if let result = fetchRemoteTodosResult {
            completion(result)
        } else {
            completion(.success([]))
        }
    }
    
    func saveTasks(_ todos: [TaskItem], completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = saveTodosResult {
            completion(result)
        } else {
            completion(.success(()))
        }
    }
    
    func fetchLocalTodos(completion: @escaping (Result<[TaskListEntity], Error>) -> Void) {
        if let result = fetchLocalTodosResult {
            completion(result)
        } else {
            completion(.success([]))
        }
    }
    
    func searchTasks(query: String, completion: @escaping (Result<[TaskListEntity], Error>) -> Void) {
        if let result = searchTodosResult {
            completion(result)
        } else {
            completion(.success([]))
        }
    }
    
    func clearLocalTasks(completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = clearLocalTodosResult {
            completion(result)
        } else {
            completion(.success(()))
        }
    }
    
    func createTask(title: String, details: String?, date: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = createTaskResult {
            completion(result)
        } else {
            completion(.success(()))
        }
    }
    
    func updateTask(taskId: Int64,
                    newTitle: String?,
                    newDecription: String?,
                    newDate: Date?,
                    newCompleted: Bool?,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = updateTaskResult {
            completion(result)
        } else {
            completion(.success(()))
        }
    }
    
    func deleteTask(taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = deleteTaskResult {
            completion(result)
        } else {
            completion(.success(()))
        }
    }
}

// MARK: - Мок для LaunchManager

final class MockLaunchManager: LaunchManager {
    var isFirstLaunch: Bool
    var didMarkLaunched = false
    
    init(isFirstLaunch: Bool) {
        self.isFirstLaunch = isFirstLaunch
    }
    
    func markAppLaunched() {
        didMarkLaunched = true
        isFirstLaunch = false
    }
}

// MARK: - Моки для модуля TaskEdit

final class MockTaskEditPresenter: TaskEditPresenter {
    var didFinishSavingCalled = false
    var didFailCalled = false
    var receivedError: Error?
    
    func viewDidLoad() { }
    func didTapBack(title: String?, details: String?) { }
    
    func didFinishSaving() {
        didFinishSavingCalled = true
    }
    
    func didFail(with error: Error) {
        didFailCalled = true
        receivedError = error
    }
}

final class MockTaskEditView: TaskEditView {
    var shownTask: TaskListEntity?
    var shownError: String?
    var didCloseCalled = false
    
    func showTask(_ task: TaskListEntity?) {
        shownTask = task
    }
    
    func showError(_ message: String) {
        shownError = message
    }
    
    func close() {
        didCloseCalled = true
    }
}

final class MockTaskEditInteractor: TaskEditInteractor {
    var didCreate = false
    var didUpdate = false
    var lastCreatedTitle: String?
    var lastUpdatedID: Int64?
    
    func createTask(title: String, details: String?) {
        didCreate = true
        lastCreatedTitle = title
    }
    
    func updateTask(id: Int64, title: String, details: String?) {
        didUpdate = true
        lastUpdatedID = id
    }
    
    func updateTask(id: UUID, title: String, description: String?) {
        // Не используется в тестах
    }
}

final class MockTaskEditRouter: TaskEditRouter {
    var didShowDiscardAlert = false
    var onDecision: ((Bool) -> Void)?
    
    func presentDiscardAlert(onDecision: @escaping (Bool) -> Void) {
        didShowDiscardAlert = true
        self.onDecision = onDecision
    }
    
    static func assembleModule(task: TaskListEntity?, repository: TaskRepository, delegate: TaskEditDelegate?) -> UIViewController {
        return UIViewController()
    }
}

final class MockTaskEditDelegate: TaskEditDelegate {
    var didFinish = false
    func didFinishEditingTask() {
        didFinish = true
    }
}

// MARK: - Моки для модуля TaskList

final class MockTaskListView: TaskListView {
    var didShowLoading = false
    var didHideLoading = false
    var shownTasks: [TaskListEntity]?
    var shownError: String?
    
    func showLoading() {
        didShowLoading = true
    }
    
    func hideLoading() {
        didHideLoading = true
    }
    
    func showTasks(_ tasks: [TaskListEntity]) {
        shownTasks = tasks
    }
    
    func showError(_ message: String) {
        shownError = message
    }
}

final class MockTaskListInteractor: TaskListInteractor {
    var didFetchTasks = false
    var didSearchTasks = false
    var lastSearchQuery: String?
    var didToggleTask: (taskId: Int64, newCompleted: Bool)?
    var didDeleteTask: Int64?
    
    func fetchTasks() {
        didFetchTasks = true
    }
    
    func searchTasks(with query: String) {
        didSearchTasks = true
        lastSearchQuery = query
    }
    
    func toggleTask(taskId: Int64, newCompleted: Bool) {
        didToggleTask = (taskId, newCompleted)
    }
    
    func deleteTask(taskId: Int64) {
        didDeleteTask = taskId
    }
}

final class MockTaskListRouter: TaskListRouter {
    static func assembleModule(repository: TaskRepository, launchManager: LaunchManager, appDependency: AppDependency, navigationController: UINavigationController) -> UIViewController {
        return UIViewController()
    }
    
    var didPresentTaskEdit = false
    var presentedTask: TaskListEntity?
    var presentedDelegate: TaskEditDelegate?
    
    func presentTaskEdit(from view: TaskListView, task: TaskListEntity?, delegate: TaskEditDelegate?) {
        didPresentTaskEdit = true
        presentedTask = task
        presentedDelegate = delegate
    }
}

final class MockTaskListPresenter: TaskListPresenter {
    var didLoadCalled = false
    var loadedTasks: [TaskListEntity]?
    
    var didFailCalled = false
    var receivedError: Error?
    
    func viewDidLoad() { }
    func didUpdateSearchQuery(_ query: String) { }
    func toggleTaskCompletion(for task: TaskListEntity) { }
    func didTapCreate() { }
    func didTapEdit(for task: TaskListEntity) { }
    func deleteTask(withId id: Int64) { }
    
    func didLoad(tasks: [TaskListEntity]) {
        didLoadCalled = true
        loadedTasks = tasks
    }
    
    func didFail(with error: Error) {
        didFailCalled = true
        receivedError = error
    }
}
