import XCTest
@testable import EffectiveToDoTest


final class TaskListInteractorTest: XCTestCase {
    
    let timeout: TimeInterval = 1.0
    
    let sampleLocalTask = TaskListEntity(id: 1, title: "Local Task", details: "Description", date: "Now", isCompleted: false)
    
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
    
 
    func test_fetchTasks_firstLaunch_success() {
        let repository = MockToDoRepository()
        let remoteToDo = TaskItem(id: 100, todo: "Remote Task", completed: false, userId: 10)
        repository.fetchRemoteTodosResult = .success([remoteToDo])
        repository.saveTodosResult = .success(())
        repository.fetchLocalTodosResult = .success([sampleLocalTask])
        
        let launchManager = MockLaunchManager(isFirstLaunch: true)
        let presenter = MockTaskListPresenter()
        let interactor = TaskListInteractorImpl(repository: repository, launchManager: launchManager)
        interactor.presenter = presenter
        
        let refreshExpectation = expectation(description: "Wait for refreshData completion")
        
        interactor.fetchTasks()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            refreshExpectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(launchManager.didMarkLaunched, "После refreshData должен вызваться markAppLaunched")
        XCTAssertTrue(presenter.didLoadCalled, "Presenter должен получить задачи после refreshData")
        XCTAssertEqual(presenter.loadedTasks?.count, 1, "Должна быть возвращена 1 локальная задача")
    }
    
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
