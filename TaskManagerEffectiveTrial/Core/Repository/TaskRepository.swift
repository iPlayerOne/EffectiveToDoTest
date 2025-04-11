import Foundation
import CoreData

protocol TaskRepository {
    func fetchRemoteTodos(completion: @escaping (Result<[TaskItem], Error>) -> Void)
    func saveTasks(_ tasks: [TaskItem], completion: @escaping (Result<Void, Error>) -> Void)
    func fetchLocalTodos(completion: @escaping (Result<[TaskListEntity], Error>) -> Void)
    func searchTasks(query: String, completion: @escaping (Result<[TaskListEntity], Error>) -> Void)
    func clearLocalTasks(completion: @escaping (Result<Void, Error>) -> Void)
    func createTask(title: String, details: String?, date: Date?, completion: @escaping (Result<Void, Error>) -> Void)
    func updateTask(taskId: Int64,
                    newTitle: String?,
                    newDecription: String?,
                    newDate: Date?,
                    newCompleted: Bool?,
                    completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTask(taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void)
}

final class TaskRepositoryImpl: TaskRepository {
    private let networkService: NetworkService
    private let coreData: CoreDataManager
    
    init(networkService: NetworkService, coreData: CoreDataManager) {
        self.networkService = networkService
        self.coreData = coreData
    }
    
    func fetchRemoteTodos(completion: @escaping (Result<[TaskItem], Error>) -> Void) {
        let endpoint = APIEndpoints.todos.url
        networkService.request(endpoint: endpoint) { (result: Result<TaskResponse, Error>) in
            switch result {
                case .success(let response):
                    completion(.success(response.todos))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func saveTasks(_ tasks: [TaskItem], completion: @escaping (Result<Void, Error>) -> Void) {
        coreData.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            tasks.forEach { task in
                let entity = TaskEntity(context: context)
                entity.id = Int64(task.id)
                entity.title = task.todo
                entity.isCompleted = task.completed
                entity.userId = Int64(task.userId)
                entity.createdAt = Date()
                //В JSON нет описания. Хардкодим.
                entity.details = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean dapibus libero vitae orci molestie volutpat."
            }
            
            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchLocalTodos(completion: @escaping (Result<[TaskListEntity], Error>) -> Void) {
        coreData.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            
            do {
                let result = try context.fetch(request)
                let dtos = result.map { $0.toDTO() }
                DispatchQueue.main.async {
                    completion(.success(dtos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func searchTasks(query: String, completion: @escaping (Result<[TaskListEntity], Error>) -> Void) {
        coreData.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            do {
                let result = try context.fetch(request)
                let dtos = result.map { $0.toDTO() }
                DispatchQueue.main.async {
                    completion(.success(dtos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func clearLocalTasks(completion: @escaping (Result<Void, Error>) -> Void) {
        coreData.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TaskEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                completion(.success(()))
            } catch {
                return completion(.failure(error))
            }
            
        }
        
    }
    
    func createTask(title: String, details: String?, date: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
        coreData.performBackgroundTask { context in
            let newTask = TaskEntity(context: context)
            
            newTask.id = Int64(Date().timeIntervalSince1970)
            newTask.title = title
            newTask.details = details
            newTask.createdAt = Date()
            newTask.isCompleted = false
            
            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateTask(taskId: Int64, newTitle: String?, newDecription: String?, newDate: Date?, newCompleted: Bool?, completion: @escaping (Result<Void,Error>) -> Void) {
        coreData.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %lld", taskId)
            request.fetchLimit = 1
            
            do {
                guard let taskEntity = try context.fetch(request).first else {
                    let error = NSError(domain: "TaskRepositoryError",
                                        code: 404,
                                        userInfo: [NSLocalizedDescriptionKey: "Task with id \(taskId) not found"])
                    completion(.failure(error))
                    return
                }
                
                taskEntity.title = newTitle ?? taskEntity.title
                taskEntity.details = newDecription ?? taskEntity.details
                taskEntity.createdAt = newDate ?? taskEntity.createdAt
                taskEntity.isCompleted = newCompleted ?? taskEntity.isCompleted
                
                if context.hasChanges {
                    try context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteTask(taskId: Int64, completion: @escaping (Result<Void,Error>) -> Void) {
        coreData.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %lld", taskId)
            request.fetchLimit = 1
            
            do {
                if let taskEntity = try context.fetch(request).first {
                    context.delete(taskEntity)
                    try context.save()
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "TaskRepositoryError",
                                        code: 404,
                                        userInfo: [NSLocalizedDescriptionKey: "Задача с id \(taskId) не найдена"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
