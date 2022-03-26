//
//  VKClient.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation

enum VKClient {

    static func login() -> URLRequest? {
        guard let url = URLLogic.loginURL() else { return nil }
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 60000
        )
        request.httpMethod = "GET"
        
        return request
    }
    
    static func photosURL(with token: String) -> URL? {
        URLLogic.photosURL(with: token)
    }
}

enum URLLogic {
    
    // swiftlint:disable:next strict_fileprivate
    fileprivate static func loginURL() -> URL? {
        let clientID = "8115098"
        let redirectURL = "&redirect_uri=https://oauth.vk.com/blank.html"
        let display = "&display=page"
        let scope = "&scope=offline"
        let responseType = "&response_type=token"
        let tokenV = "&v=5.131"
        
        return .init(
            string: BaseURLs.login.rawValue + clientID + display + redirectURL + scope + responseType + tokenV
        )
    }
    
    // swiftlint:disable:next strict_fileprivate
    fileprivate static func photosURL(with token: String) -> URL? {
    
        let ownerID = "-128666765"
        let albumID = "&album_id=266276915"
        let accseccToken = "&access_token="
        let tokenV = "&v=5.131"
        
        return .init(
            string: BaseURLs.photos.rawValue + ownerID + albumID + accseccToken + token + tokenV
        )
    }
    
    private enum BaseURLs: String {
        case login = "https://oauth.vk.com/authorize?client_id="
        case photos = "https://api.vk.com/method/photos.get?owner_id="
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
