//
//  Model.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation

// MARK: - Welcome
struct VKResponse: Codable {
    let album: Album
    enum CodingKeys: String, CodingKey {
        case album = "response"
    }
}

// MARK: - Response
struct Album: Codable {
    let count: Int
    let photos: [Photo]
    enum CodingKeys: String, CodingKey {
        case count
        case photos = "items"
    }
}

// MARK: - Item
struct Photo: Codable, Hashable {
    
    let albumID, date, id, ownerID: Int
    let sizes: [Size]
    let text: String
    let userID: Int
    let hasTags: Bool

    enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case date, id
        case ownerID = "owner_id"
        case sizes, text
        case userID = "user_id"
        case hasTags = "has_tags"
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.date == rhs.date
    }
}

// MARK: - Size
struct Size: Codable, Hashable {
    let height: Int
    let url: String
    let type: TypeEnum
    let width: Int
}


enum TypeEnum: String, Codable {
    case m
    case o
    case p
    case q
    case r
    case s
    case w
    case x
    case y
    case z
}
