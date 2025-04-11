import XCTest
@testable import EffectiveToDoTest

// MARK: - Мок презентера

final class MockPresenter: TaskEditPresenter {
    var didFinishSavingCalled = false
    var didFailCalled = false
    var receivedError: Error?
    
    // Методы, которые нам не нужны в тестах, оставим пустыми
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

// MARK: - Тесты для интерактора

final class TaskEditInteractorTest: XCTestCase {
    
    func test_createTask_success_callsDidFinishSaving() {
        let mockRepo = MockToDoRepository()
        mockRepo.createTaskResult = .success(())
        
        let interactor = TaskEditInteractorImpl(repository: mockRepo)
        let mockPresenter = MockPresenter()
        interactor.presenter = mockPresenter
        

        interactor.createTask(title: "Новая задача", details: "Описание задачи")
        

        XCTAssertTrue(mockPresenter.didFinishSavingCalled, "Метод didFinishSaving должен быть вызван при успешном создании задачи")
        XCTAssertFalse(mockPresenter.didFailCalled, "Метод didFail не должен быть вызван при успешном создании задачи")
    }
    
    func test_createTask_failure_callsDidFail() {
        let mockRepo = MockToDoRepository()
        let sampleError = NSError(domain: "test", code: 1, userInfo: nil)
        mockRepo.createTaskResult = .failure(sampleError)
        
        let interactor = TaskEditInteractorImpl(repository: mockRepo)
        let mockPresenter = MockPresenter()
        interactor.presenter = mockPresenter
        

        interactor.createTask(title: "Новая задача", details: "Описание задачи")
        
  
        XCTAssertFalse(mockPresenter.didFinishSavingCalled, "Метод didFinishSaving не должен вызываться при ошибке создания задачи")
        XCTAssertTrue(mockPresenter.didFailCalled, "Метод didFail должен быть вызван при ошибке создания задачи")
        XCTAssertEqual((mockPresenter.receivedError as NSError?)?.code, sampleError.code)
    }
    
    func test_updateTask_success_callsDidFinishSaving() {
        let mockRepo = MockToDoRepository()
        mockRepo.updateTaskResult = .success(())
        
        let interactor = TaskEditInteractorImpl(repository: mockRepo)
        let mockPresenter = MockPresenter()
        interactor.presenter = mockPresenter
        
   
        interactor.updateTask(id: 42, title: "Обновлённый заголовок", details: "Новое описание")
        
        XCTAssertTrue(mockPresenter.didFinishSavingCalled, "Метод didFinishSaving должен быть вызван при успешном обновлении задачи")
        XCTAssertFalse(mockPresenter.didFailCalled, "Метод didFail не должен вызываться при успешном обновлении задачи")
    }
    
    func test_updateTask_failure_callsDidFail() {
        let mockRepo = MockToDoRepository()
        let sampleError = NSError(domain: "test", code: 2, userInfo: nil)
        mockRepo.updateTaskResult = .failure(sampleError)
        
        let interactor = TaskEditInteractorImpl(repository: mockRepo)
        let mockPresenter = MockPresenter()
        interactor.presenter = mockPresenter
        
 
        interactor.updateTask(id: 42, title: "Обновлённый заголовок", details: "Новое описание")
        
        XCTAssertFalse(mockPresenter.didFinishSavingCalled, "Метод didFinishSaving не должен вызываться при ошибке обновления задачи")
        XCTAssertTrue(mockPresenter.didFailCalled, "Метод didFail должен быть вызван при ошибке обновления задачи")
        XCTAssertEqual((mockPresenter.receivedError as NSError?)?.code, sampleError.code)
    }
}
