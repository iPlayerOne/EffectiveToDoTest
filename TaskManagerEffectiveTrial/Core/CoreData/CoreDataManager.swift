import CoreData

final class CoreDataManager {
    let container: NSPersistentContainer
    
    init(modelName: String = "TaskModel") {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}
