import Foundation

protocol LaunchManager {
    var isFirstLaunch: Bool { get }
    func markAppLaunched()
}

final class LaunchManagerImpl: LaunchManager {
    private let defaults: UserDefaultsManager
    private let key = "didLaunchBefore"
    
    init(defaults: UserDefaultsManager) {
        self.defaults = defaults
    }
    
    var isFirstLaunch: Bool {
        let launchedBefore = defaults.get(forKey: key, type: Bool.self) ?? false
        return !launchedBefore
    }
    
    func markAppLaunched() {
        defaults.set(true, forKey: key)
    }
}
