import XCTest
@testable import EffectiveToDoTest


final class TaskListPresenterTest: XCTestCase {
    
    func test_viewDidLoad_showsLoadingAndFetchesTasks() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(view.didShowLoading, "view.showLoading() должен быть вызван")
        XCTAssertTrue(interactor.didFetchTasks, "interactor.fetchTasks() должен быть вызван")
    }
    
    func test_didLoad_hidesLoadingAndShowsTasks() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        let tasks: [TaskListEntity] = [
            TaskListEntity(id: 1, title: "Task 1", details: "Desc 1", date: "Now", isCompleted: false),
            TaskListEntity(id: 2, title: "Task 2", details: "Desc 2", date: "Now", isCompleted: true)
        ]
        
        presenter.didLoad(tasks: tasks)
        
        XCTAssertTrue(view.didHideLoading, "view.hideLoading() должен быть вызван")
        XCTAssertEqual(view.shownTasks?.count, tasks.count, "view.showTasks() должен быть вызван с корректным количеством задач")
    }
    
    func test_didFail_hidesLoadingAndShowsError() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        let sampleError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Error occurred"])
        presenter.didFail(with: sampleError)
        
        XCTAssertTrue(view.didHideLoading, "view.hideLoading() должен быть вызван")
        XCTAssertEqual(view.shownError, sampleError.localizedDescription, "view.showError() должен быть вызван с текстом ошибки")
    }
    
    func test_didUpdateSearchQuery_withEmptyQuery_fetchesTasks() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        presenter.didUpdateSearchQuery("   ") // Пустая строка после обрезки пробелов
        
        XCTAssertTrue(interactor.didFetchTasks, "interactor.fetchTasks() должен быть вызван при пустом поисковом запросе")
        XCTAssertFalse(interactor.didSearchTasks, "interactor.searchTasks() не должен вызываться при пустом поисковом запросе")
    }
    
    func test_didUpdateSearchQuery_withNonEmptyQuery_searchesTasks() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        let query = "Test"
        presenter.didUpdateSearchQuery(query)
        
        XCTAssertTrue(interactor.didSearchTasks, "interactor.searchTasks() должен быть вызван при непустом поисковом запросе")
        XCTAssertEqual(interactor.lastSearchQuery, query, "Поисковый запрос должен передаваться корректно")
    }
    
    func test_toggleTaskCompletion_callsToggleTaskWithInvertedCompletion() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        let task = TaskListEntity(id: 100, title: "Task", details: "Desc", date: "Now", isCompleted: false)
        presenter.toggleTaskCompletion(for: task)
        
        XCTAssertNotNil(interactor.didToggleTask, "interactor.toggleTask должен быть вызван")
        XCTAssertEqual(interactor.didToggleTask?.taskId, task.id, "ID задачи должны совпадать")
        XCTAssertEqual(interactor.didToggleTask?.newCompleted, true, "newCompleted должен быть противоположным исходному (true)")
    }
    
    func test_didTapCreate_callsPresentTaskEditWithNilTask() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        // Устанавливаем view, чтобы guard в презентере прошёл
        presenter.view = view
        
        presenter.didTapCreate()
        
        XCTAssertTrue(router.didPresentTaskEdit, "router.presentTaskEdit должен быть вызван для создания задачи")
        XCTAssertNil(router.presentedTask, "Для создания задачи параметр task должен быть nil")
        XCTAssertTrue(router.presentedDelegate === presenter, "Делегатом должен быть сам презентер")
    }
    
    func test_didTapEdit_callsPresentTaskEditWithSpecifiedTask() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        presenter.view = view
        let task = TaskListEntity(id: 200, title: "Task Edit", details: "Desc", date: "Now", isCompleted: false)
        presenter.didTapEdit(for: task)
        
        XCTAssertTrue(router.didPresentTaskEdit, "router.presentTaskEdit должен быть вызван для редактирования задачи")
        XCTAssertEqual(router.presentedTask?.id, task.id, "Параметр task должен совпадать с задачей для редактирования")
    }
    
    func test_deleteTask_showsLoadingAndCallsDeleteTask() {
        let view = MockTaskListView()
        let interactor = MockTaskListInteractor()
        let router = MockTaskListRouter()
        let presenter = TaskListPresenterImpl(view: view, interactor: interactor, router: router)
        
        let taskId: Int64 = 555
        presenter.deleteTask(withId: taskId)
        
        XCTAssertTrue(view.didShowLoading, "view.showLoading() должен быть вызван при удалении задачи")
        XCTAssertEqual(interactor.didDeleteTask, taskId, "interactor.deleteTask должен быть вызван с корректным id")
    }
}
