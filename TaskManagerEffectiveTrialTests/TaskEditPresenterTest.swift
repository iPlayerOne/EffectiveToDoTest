import XCTest
@testable import EffectiveToDoTest

final class TaskEditPresenterTest: XCTestCase {

    final class MockView: TaskEditView {
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

    final class MockInteractor: TaskEditInteractor {
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

        func updateTask(id: UUID, title: String, description: String?) {}
    }

    final class MockRouter: TaskEditRouter {
        var didShowDiscardAlert = false
        var onDecision: ((Bool) -> Void)?

        func presentDiscardAlert(onDecision: @escaping (Bool) -> Void) {
            didShowDiscardAlert = true
            self.onDecision = onDecision
        }

        static func assembleModule(task: TaskListEntity?, repository: TaskRepository, delegate: TaskEditDelegate?) -> UIViewController {
            UIViewController()
        }
    }

    final class MockDelegate: TaskEditDelegate {
        var didFinish = false
        func didFinishEditingTask() {
            didFinish = true
        }
    }


    func test_viewDidLoad_showsInitialTask() {
        let task = TaskListEntity(id: 42, title: "Title", details: "Desc", date: "Now", isCompleted: false)
        let view = MockView()
        let presenter = TaskEditPresenterImpl(view: view, interactor: MockInteractor(), router: MockRouter(), task: task)

        presenter.viewDidLoad()

        XCTAssertEqual(view.shownTask?.id, 42)
        XCTAssertEqual(view.shownTask?.title, "Title")
    }

    func test_didFinishSaving_closesViewAndNotifiesDelegate() {
        let view = MockView()
        let delegate = MockDelegate()
        let presenter = TaskEditPresenterImpl(view: view, interactor: MockInteractor(), router: MockRouter(), task: nil)
        presenter.delegate = delegate

        // Создаем ожидание, чтобы дождаться выполнения асинхронного кода
        let expectation = self.expectation(description: "Wait for didFinishSaving to complete")
        
        presenter.didFinishSaving()

        DispatchQueue.main.async {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertTrue(view.didCloseCalled)
        XCTAssertTrue(delegate.didFinish)
    }

    func test_didFail_displaysError() {
        let view = MockView()
        let presenter = TaskEditPresenterImpl(view: view, interactor: MockInteractor(), router: MockRouter(), task: nil)
        let error = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])

        let expectation = self.expectation(description: "Wait for didFail to complete")
        presenter.didFail(with: error)
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(view.shownError, "Something went wrong")
    }

    func test_didTapBack_whenEditingAndTitleEmpty_showsError() {
        let view = MockView()
        let interactor = MockInteractor()
        let router = MockRouter()
        let task = TaskListEntity(id: 1, title: "Old", details: "", date: "Now", isCompleted: false)

        let presenter = TaskEditPresenterImpl(view: view, interactor: interactor, router: router, task: task)
        presenter.didTapBack(title: "   ", details: "Some desc")

        XCTAssertEqual(view.shownError, "Заголовок зачем-то не может быть пустым 🤷‍♂️")
    }

    func test_didTapBack_whenBothTitleAndDescriptionEmpty_closesView() {
        let view = MockView()
        let interactor = MockInteractor()
        let router = MockRouter()
        let presenter = TaskEditPresenterImpl(view: view, interactor: interactor, router: router, task: nil)
        presenter.didTapBack(title: "   ", details: "   ")

        XCTAssertTrue(view.didCloseCalled)
    }
}
