import Foundation

final class AppDependency {
    let coreDataManager = CoreDataManager()
    let networkService = NetworkServiceImpl()
    let userDefaults = UserDefaultsManagerImpl()
    
    lazy var TaskRepository = TaskRepositoryImpl(
        networkService: networkService,
        coreData: coreDataManager
    )
    
    lazy var launchManager: LaunchManager = LaunchManagerImpl(defaults: userDefaults)

}

