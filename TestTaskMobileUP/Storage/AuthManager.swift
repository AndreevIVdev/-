//
//  Storage.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation
import WebKit

enum AuthState {
    case authorized
    case unauthorized
    case error
}

class AuthManager {
    
    private init() {
        if UserDefaults.standard.string(forKey: "access_token") != nil {
            state = .authorized
        } else {
            state = .unauthorized
        }
    }
    
    static let shared = AuthManager()
    
    @Published private(set) var state: AuthState

    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
        state = .authorized
    }
    
    func getToken() -> String? {
        UserDefaults.standard.string(forKey: "access_token")
    }
    
    func logoutFromCurrentAccount() {
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
}
