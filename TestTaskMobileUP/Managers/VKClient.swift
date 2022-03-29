//
//  VKClient.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation

// MARK: - Class VKClient
enum VKClient {
    
    // MARK: - Private Properties
    private static let serviceKey = "53e93def53e93def53e93def625392ee75553e953e93def31d4a7180af75e647e8a29c9"
    private static let secretKey = "gDcz0C4Voxs80UcvWKMd"
    private static let tokenV = "&v=5.131"
    private enum BaseURLs: String {
        case login = "https://oauth.vk.com/authorize?client_id="
        case photos = "https://api.vk.com/method/photos.get?owner_id="
        case validation = "https://api.vk.com/method/secure.checkToken?token="
    }
    
    // MARK: - Public Static Methods
    static func loginURL() -> URL? {
        let clientID = "8115098"
        let redirectURL = "&redirect_uri=https://oauth.vk.com/blank.html"
        let display = "&display=page"
        let scope = "&scope=offline"
        let responseType = "&response_type=token"
        
        return .init(
            string: BaseURLs.login.rawValue + clientID + display + redirectURL + scope + responseType + tokenV
        )
    }
    
    static func photosURL(with token: String) -> URL? {
    
        let ownerID = "-128666765"
        let albumID = "&album_id=266276915"
        let accessToken = "&access_token="
        
        return .init(
            string: BaseURLs.photos.rawValue + ownerID + albumID + accessToken + token + tokenV
        )
    }
    
    static func getTokenFrom(url: URL) -> String? {
        
        URLComponents(
            string: url.absoluteString.replacingOccurrences(of: "#", with: "?")
        )?
            .queryItems?
            .first { $0.name == "access_token" }?
            .value
    }
    
    static func validationURL(with token: String) -> URL? {
    
        let accessToken = "&access_token="
        let clientSecret = "&client_secret="
        
        return .init(
            string: BaseURLs.validation.rawValue
            + token
            + accessToken
            + Self.serviceKey
            + clientSecret
            + Self.secretKey
            + tokenV
        )
    }
    
    static func isAccessDenied(url: URL) -> Bool {
        url.absoluteString.lowercased().range(of: "access_denied") != nil
    }
}
