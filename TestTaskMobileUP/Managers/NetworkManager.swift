//
//  NetworkManager.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation

// MARK: - Class NetworkManager
final class NetworkManager {
    
    // MARK: - Public Static Properties
    static let shared = NetworkManager()
    
    // MARK: - Private Properties
    private let cache: NSCache<NSString, NSData> = .init()
    private var loadingResponses: [URL: [(Data?) -> Void]] = .init()
    
    // MARK: - Initializers
    private init() {
        print("\(String(describing: type(of: self))) INIT")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Public Methods
    func fetchData(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    ) {
        
        if let nsdata = self.cache.object(forKey: url.description as NSString) {
            completed(.success(Data(referencing: nsdata)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                completed(.failure(TTError.serverProblem))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(TTError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(TTError.noData))
                return
            }
            
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
            
            completed(.success(data))
        }
        .resume()
    }
    
    
    func fetchDataAvoidingCache(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard error == nil else {
                completed(.failure(TTError.serverProblem))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(TTError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(TTError.noData))
                return
            }
            
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
            
            completed(.success(data))
        }
        .resume()
    }
    
    func fetchDataWithOutErrorHandling(
        from url: URL,
        completed: @escaping (Data?) -> Void
    ) {
        if let nsdata = self.cache.object(forKey: url.description as NSString) {
            completed(Data(referencing: nsdata))
            return
        }
        
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completed)
            return
        } else {
            loadingResponses[url] = [completed]
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            self.loadingResponses[url]?.forEach { $0(data) }
            self.loadingResponses.removeValue(forKey: url)
            guard let data = data else { return }
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
        }
        .resume()
    }
}
