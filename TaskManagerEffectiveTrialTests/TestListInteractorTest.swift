import XCTest
@testable import EffectiveToDoTest


// MARK: - Тесты для TaskListInteractorImpl

final class TaskListInteractorTest: XCTestCase {
    
    // Установим небольшой timeout для ожидания асинхронных вызовов
    let timeout: TimeInterval = 1.0
    
    // Пример локальной задачи для fetchLocalTodos
    let sampleLocalTask = TaskListEntity(id: 1, title: "Local Task", details: "Description", date: "Now", isCompleted: false)
    
    // Тест, когда это НЕ первый запуск: сразу вызывается fetchLocalTodos
    func test_fetchTasks_notFirstLaunch_success() {
        let repository = MockToDoRepository()
        repository.fetchLocalTodosResult = .success([sampleLocalTask])
        
        let launchManager = MockLaunchManager(isFirstLaunch: false)
        let presenter = MockTaskListPresenter()
        let interactor = TaskListInteractorImpl(repository: repository, launchManager: launchManager)
        interactor.presenter = presenter
        
        let fetchExpectation = expectation(description: "Wait for fetchLocalTodos completion")
        
        interactor.fetchTasks()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            fetchExpectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(presenter.didLoadCalled, "Presenter должен получить задачи при fetchLocalTodos")
        XCTAssertEqual(presenter.loadedTasks?.count, 1, "Должна быть возвращена 1 локальная задача")
        XCTAssertFalse(launchManager.didMarkLaunched, "Если не первый запуск, markAppLaunched не должен вызываться")
    }
    
    // Тест, когда это первый запуск: интерактор должен выполнить refreshData через fetchRemoteTodos, saveTodos, а затем fetchLocalTodos, и вызвать markAppLaunched
    func test_fetchTasks_firstLaunch_success() {
        let repository = MockToDoRepository()
        // Задаём результат для fetchRemoteTodos: например, удалённая задача (используем ToDo, как определено в проекте)
        let remoteToDo = TaskItem(id: 100, todo: "Remote Task", completed: false, userId: 10)
        repository.fetchRemoteTodosResult = .success([remoteToDo])
        repository.saveTodosResult = .success(())
        // После сохранения удалённых задач, возвращаем локальную задачу
        repository.fetchLocalTodosResult = .success([sampleLocalTask])
        
        let launchManager = MockLaunchManager(isFirstLaunch: true)
        let presenter = MockTaskListPresenter()
        let interactor = TaskListInteractorImpl(repository: repository, launchManager: launchManager)
        interactor.presenter = presenter
        
        let refreshExpectation = expectation(description: "Wait for refreshData completion")
        
        interactor.fetchTasks()
        
        // Для тестирования цепочки (fetchRemoteTodos -> saveTodos -> fetchLocalTodos) даём немного больше времени
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            refreshExpectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(launchManager.didMarkLaunched, "После refreshData должен вызваться markAppLaunched")
        XCTAssertTrue(presenter.didLoadCalled, "Presenter должен получить задачи после refreshData")
        XCTAssertEqual(presenter.loadedTasks?.count, 1, "Должна быть возвращена 1 локальная задача")
    }
    
    // Тест успешного toggleTask, где после обновления задачи вызывается fetchLocalTodos
    func test_toggleTask_success() {
        let repository = MockToDoRepository()
        repository.updateTaskResult = .success(())
        repository.fetchLocalTodosResult = .success([sampleLocalTask])
        
        let launchManager = MockLaunchManager(isFirstLaunch: false)
        let presenter = MockTaskListPresenter()
        let interactor = TaskListInteractorImpl(repository: repository, launchManager: launchManager)
        interactor.presenter = presenter
        
        let toggleExpectation = expectation(description: "Wait for toggleTask completion")
        
        interactor.toggleTask(taskId: sampleLocalTask.id, newCompleted: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toggleExpectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(presenter.didLoadCalled, "После toggleTask должен быть вызван fetchLocalTodos и presenter.didLoad")
        XCTAssertFalse(presenter.didFailCalled, "При успешном toggleTask presenter.didFail не должен вызываться")
    }
    
    // Тест ошибки при удалении задачи: если deleteTask возвращает ошибку, интерактор должен вызвать presenter.didFail
    func test_deleteTask_failure() {
        let repository = MockToDoRepository()
        let sampleError = NSError(domain: "Test", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        repository.deleteTaskResult = .failure(sampleError)
        
        let launchManager = MockLaunchManager(isFirstLaunch: false)
        let presenter = MockTaskListPresenter()
        let interactor = TaskListInteractorImpl(repository: repository, launchManager: launchManager)
        interactor.presenter = presenter
        
        let deleteExpectation = expectation(description: "Wait for deleteTask completion")
        
        interactor.deleteTask(taskId: sampleLocalTask.id)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            deleteExpectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(presenter.didFailCalled, "При ошибке deleteTask должен быть вызван presenter.didFail")
        XCTAssertFalse(presenter.didLoadCalled, "При ошибке deleteTask presenter.didLoad не должен вызываться")
        XCTAssertEqual((presenter.receivedError as NSError?)?.code, sampleError.code)
    }
}
