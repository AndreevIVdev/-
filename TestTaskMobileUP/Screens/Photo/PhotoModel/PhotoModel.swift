//
//  PhotoModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import Foundation
import Combine

class PhotoModel {
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func loadAlbum(completion: @escaping (Result<Album, Error>) -> Void) {
            guard let url = VKClient.photosURL(with: self.token) else { return }
            NetworkingManager.shared.fetchData(from: url) { result in
                switch result {
                case .success(let data):
                    do {
                        completion(.success(try JSONDecoder().decode(VKResponse.self, from: data).album))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func loadPhoto(index: Int, from album: Album, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: album.photos[index].sizes[4].url) else { return }
        NetworkingManager.shared.fetchDataWithOutErrorHandling(from: url) { data in
            completion(data)
        }
    }
}
