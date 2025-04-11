import Foundation

protocol NetworkService {
    func request<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void)
}

final class NetworkServiceImpl: NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            return completion(.failure(URLError(.badURL)))
        }
        
        let request = URLRequest(url: url)
        
        DispatchQueue.global(qos: .background).async {
            self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    return completion(.failure(error))
                }
                
                guard let data = data, let response = response else {
                    return completion(.failure(URLError(.badServerResponse)))
                }
                
                do {
                    try self.validateResponse(response)
                    let decoded = try self.decodeJSON(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func decodeJSON<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let json = String(data: data, encoding: .utf8) {
                print("Failed to decode JSON: \(json)")
            }
            throw error
        }
    }
}

