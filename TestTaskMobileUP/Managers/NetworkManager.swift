//
//  NetworkManager.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation


final class NetworkingManager {
    
    private init() {}
    
    static let shared = NetworkingManager()
    
    let cache: NSCache<NSString, NSData> = .init()
    
    public func fetchData(
        from url: URL,
        completed: @escaping (Result<Data, Error>) -> Void
    ) {
        DispatchQueue.global().async {
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
    }
    
    public func fetchDataAvoidingCache(
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
    
    public func fetchDataAvoidingCacheWithOutErrorHandling(
        from url: URL,
        completed: @escaping (Data?) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            completed(data)
            
            guard let self = self,
                  let data = data else { return }
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
        }
        .resume()
    }
    
    public func fetchDataWithOutErrorHandling(
        from url: URL,
        completed: @escaping (Data?) -> Void
    ) {
        if let nsdata = self.cache.object(forKey: url.description as NSString) {
            completed(Data(referencing: nsdata))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            completed(data)
            
            guard let self = self,
                  let data = data else { return }
            self.cache.setObject(NSData(data: data), forKey: url.description as NSString)
        }
        .resume()
    }
}
