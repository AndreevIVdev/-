//
//  VKClient.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation

class VKClient: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    lazy var connection: URLSession = {
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        return session
    }()

    static func login() -> URLRequest {
        
        var request = URLRequest(
            url: URLLogic.urlFor(actionTask: .login),
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 60000
        )
        request.httpMethod = "GET"
        
        return request
    }
    
    static func getTokenFrom(url: URL) -> String? {
        URLLogic.getTokenFrom(url: url)
    }
    
    static func isAccessDenied(url: URL) -> Bool {
        URLLogic.isAccessDenied(url: url)
    }
}

private enum URLLogic {
    
    static func urlFor(actionTask: ActionTask, addition: String? = nil) -> URL {
        let clientID = "8115098"
        let redirectURL = "&redirect_uri=https://oauth.vk.com/blank.html"
        let display = "&display=page"
        let scope = "&scope=offline"
        let responseType = "&response_type=token"
        let tokenV = "&v=5.131"
        
        switch actionTask {
        case .login:
            guard let url = URL(
                string: actionTask.rawValue + clientID + display + redirectURL + scope + responseType + tokenV
            ) else { return URL("https://ya.ru") }
            return url
        }
    }
    
    enum ActionTask: String {
        case login = "https://oauth.vk.com/authorize?client_id="
    }
    
    static func getTokenFrom(url: URL) -> String? {
        
        URLComponents(
            string: url.absoluteString.replacingOccurrences(of: "#", with: "?")
        )?
            .queryItems?
            .first { $0.name == "access_token" }?
            .value
    }
    
    static func isAccessDenied(url: URL) -> Bool {
        url.absoluteString.lowercased().range(of: "access_denied") != nil
    }
}
