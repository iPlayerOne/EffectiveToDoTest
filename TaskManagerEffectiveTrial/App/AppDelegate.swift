
import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var dependencies = AppDependency()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navController = UINavigationController()
        let rootVC = TaskListRouterImpl.assembleModule(
                    repository: dependencies.TaskRepository,
                    launchManager: dependencies.launchManager,
                    appDependency: dependencies,
                    navigationController: navController
                )
        
        navController.viewControllers = [rootVC]
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }

}

