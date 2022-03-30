//
//  Storage.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation
import WebKit
import Combine

// MARK: - Class AuthManager
final class AuthManager {
    
    // MARK: - Publishers
    /// Current application state publisher
    @Published private(set) var state: AuthState = .undefined
    /// Possible error publisher
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    // MARK: - Public Static Properties
    /// The only one instance of Authorisation manager
    static let shared = AuthManager()
    
    // MARK: - Private Properties
    /// Subscriptions storage
    private var bindings: Set<AnyCancellable> = .init()
    
    // MARK: - Initializers
    private init() {
        $state.sink { state in
            print("NEW APPSTATE --> \(state)".uppercased())
        }
        .store(in: &bindings)
    }
    
    // MARK: - Public Methods
    /// Сurrent application state request
    /// - Parameter completion: Asynchronously returns result
    func isLoggedIn(completion: ((Bool) -> Void)? = nil) {
        if let token = getToken() {
            validateToken(with: token) { [weak self] result in
                guard let self = self else {
                    completion?(false)
                    return
                }
                switch result {
                case .success(let valid):
                    if valid {
                        self.state = .authorized
                    } else {
                        self.error.send(TTError.invalidToken)
                    }
                    completion?(valid)
                case .failure(let error):
                    self.error.send(error)
                    completion?(false)
                }
            }
        } else {
            state = .unauthorized
            completion?(false)
        }
    }
    
    /// Saves the new token
    /// - Parameter token: new value
    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
        UserDefaults.standard.synchronize()
        state = .authorized
    }
    
    /// Returns the current application token
    /// - Returns: optional token value
    func getToken() -> String? {
        UserDefaults.standard.string(forKey: "access_token")
    }
    
    /// Logs out of current account and deletes the token
    func logoutFromCurrentAccount() {
        if getToken() == nil {
            return
        }
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.synchronize()
        
        let cookies = HTTPCookieStorage.shared.cookies
        for cookie in cookies! {
            if cookie.domain.range(of: "vk.com") != nil {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {}
            }
        }
        
        state = .unauthorized
    }
    
    /// If something went wrong puts the application in an safe state
    func undefine() {
        state = .undefined
    }
    
    // MARK: - Private Methods
    /// Checks given token is it valid or not
    /// - Parameters:
    ///   - token: token for check
    ///   - completion: result in completion block
    private func validateToken(with token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = VKClient.validationURL(with: token) else {
            completion(.failure(TTError.internalError))
            return
        }
        NetworkManager.shared.fetchDataAvoidingCache(from: url) { result in
            switch result {
            case .success(let data):
                do {
                    let validationResponse = try JSONDecoder().decode(VKValidationResponse.self, from: data)
                    completion(.success(validationResponse.response.success == 1))
                } catch {
                    completion(.failure(TTError.invalidToken))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Enum AuthState
/// Three possible application states
enum AuthState: Equatable {
    case authorized
    case unauthorized
    case undefined
}
