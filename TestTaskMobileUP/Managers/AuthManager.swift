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
    @Published private(set) var state: AuthState = .undefined
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    // MARK: - Public Static Properties
    static let shared = AuthManager()
    
    // MARK: - Private Properties
    private var bindings: Set<AnyCancellable> = .init()
    
    // MARK: - Initializers
    private init() {
        $state.sink { state in
            print("NEW APPSTATE --> \(state)".uppercased())
        }
        .store(in: &bindings)
        print("\(String(describing: type(of: self))) INIT")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Public Methods
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

    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
        UserDefaults.standard.synchronize()
        state = .authorized
    }
    
    func getToken() -> String? {
        UserDefaults.standard.string(forKey: "access_token")
    }
    
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
    
    func undefine() {
        state = .undefined
    }
    
    // MARK: - Private Methods
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
enum AuthState: Equatable {
    case authorized
    case unauthorized
    case undefined
}
