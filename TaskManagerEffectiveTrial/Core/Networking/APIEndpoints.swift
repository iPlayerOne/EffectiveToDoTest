import Foundation

enum APIEndpoints {
    static let baseURL = "https://dummyjson.com"
    
    case todos
    
    var url: String {
        switch self {
            case .todos:
                return "\(APIEndpoints.baseURL)/todos"
        }
    }
}

