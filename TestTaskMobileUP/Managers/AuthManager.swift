//
//  Storage.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation
import WebKit
import Combine

enum AuthState: Equatable {
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
            
        case (.authorized, .authorized),
            (.unauthorized, .unauthorized),
            (.undefined, .undefined):
            return true
        default:
            return false
        }
    }
    
    case authorized
    case unauthorized
    case undefined
}

class AuthManager {
    
    private var bindings: Set<AnyCancellable> = .init()
    
    private init() {
        $state.sink { state in
            print("NEW APPSTATE --> \(state)".uppercased())
        }
        .store(in: &bindings)
    }
    
    static let shared = AuthManager()
    
    @Published private(set) var state: AuthState = .undefined
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    func isLoggedIn(completion: ((Bool) -> Void)? = nil) {
        if let token = UserDefaults.standard.string(forKey: "access_token") {
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
    
    private func validateToken(with token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = VKClient.validationURL(with: token) else {
            completion(.failure(TTError.internalError))
            return
        }
        NetworkingManager.shared.fetchDataAvoidingCache(from: url) { result in
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
