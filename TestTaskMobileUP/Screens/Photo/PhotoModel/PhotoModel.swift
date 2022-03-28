//
//  PhotoModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import Foundation
import Combine
import UIKit

class PhotoModel {
    private let token: String
    private var dataSource: [Data?] = []
    private var bindings: Set<AnyCancellable> = .init()
    private(set) var photosCount: PassthroughSubject<Int, Never> = .init()
    private(set) var initializationDone: PassthroughSubject<Void, Never> = .init()
    private var album: CurrentValueSubject<Album?, Never> = .init(nil)
    
    init(token: String) {
        self.token = token
        bind()
        loadAlbum { [weak self] in
            guard let self = self else { return }
            self.loadPhotos()
        }
    }
    
    func getPhoto(for index: Int, completion: @escaping (Data?, Int) -> Void) {
        guard index < dataSource.count,
              let album = album.value else {
            return
        }
        
        if let data = dataSource[index] {
            completion(data, index)
            return
        }
        
        loadPhoto(index: index, from: album) { [weak self] data in
            guard let self = self else {
                return
            }
            self.dataSource[index] = data
            completion(data, index)
        }
    }
    
    func getTitle(for index: Int) -> Int? {
        guard let album = album.value,
              index < album.count  else { return nil }
        
        return album.photos[index].date
    }
    
    private func bind() {
        album
            .compactMap { $0 }
            .sink { [unowned self] album in
                self.dataSource = .init(repeating: nil, count: album.count)
                self.photosCount.send(album.count)
            }
            .store(in: &bindings)
    }
    
    func loadAlbum(completed: @escaping () -> Void) {
        guard let url = VKClient.photosURL(with: self.token) else { return }
        NetworkingManager.shared.fetchData(from: url) { [weak self] result in
            defer {
                completed()
            }
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    self.album.send(try JSONDecoder().decode(VKResponse.self, from: data).album)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadPhotos() {
        guard let album = album.value else { return }
        let group = DispatchGroup()
        for index in dataSource.indices {
            DispatchQueue.global().async {
                group.enter()
                self.loadPhoto(index: index, from: album) { [weak self] data in
                    group.leave()
                    guard let self = self else { return }
                    self.dataSource[index] = data
                }
            }
        }
        
        group.notify(queue: .global()) {
            self.initializationDone.send()
        }
    }
    
    private func loadPhoto(index: Int, from album: Album, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: album.photos[index].sizes[4].url) else {
            completion(nil)
            return
        }
        NetworkingManager.shared.fetchDataWithOutErrorHandling(from: url) { data in
            completion(data)
        }
    }
}
