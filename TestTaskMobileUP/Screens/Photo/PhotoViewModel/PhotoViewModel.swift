//
//  PhotoViewModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import Foundation
import Combine

class PhotoViewModel {
    
    private(set) var title: CurrentValueSubject<String, Never> = .init("")
    private(set) var photo: CurrentValueSubject<Data, Never> = .init(Images.placeholder.pngData()!)
    private(set) var currentIndex: CurrentValueSubject<Int, Never> = .init(0)
    private(set) var dataSource: CurrentValueSubject<[Data?], Never> = .init([])
    
    private var bindings: Set<AnyCancellable> = .init()
    private let model: PhotoModel
    private var album: Album?
    
    init(token: String, currentindex: Int) {
        model = .init(token: token)
        self.currentIndex.send(currentindex)
        bind()
        loadAlbum()
        loadDataSource()
    }
    
    func setNewIndex(_ newIndex: Int) {
        currentIndex.send(newIndex)
    }
    
    private func bind() {
        currentIndex
            .sink { [unowned self] _ in
                updateTitle()
            }
            .store(in: &bindings)
        
        currentIndex
            .sink { [unowned self] _ in
                self.updatePhoto()
            }
            .store(in: &bindings)
    }
    
    private func loadAlbum() {
        model.loadAlbum { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let album):
                self.album = album
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadDataSource() {
        guard let album = album else { return }
        dataSource.send([Data?](repeating: nil, count: album.count))
        let group = DispatchGroup()
        for index in self.dataSource.value.indices {
            group.enter()
            model.loadPhoto(index: index, from: album) { [weak self] data in
                group.leave()
                guard let self = self else { return }
                self.dataSource.value[index] = data
            }
            group.notify(queue: .global()) {
                self.updateTitle()
                self.updatePhoto()
            }
        }
    }
    
    private func updateTitle() {
        guard let album = album,
              currentIndex.value < album.photos.count else {
                  return
              }
        title.send(album.photos[currentIndex.value].date.convertToTime())
    }
    
    private func updatePhoto() {
        guard currentIndex.value < dataSource.value.count,
              let data = dataSource.value[currentIndex.value] else {
                  return
              }
        photo.send(data)
    }
}
