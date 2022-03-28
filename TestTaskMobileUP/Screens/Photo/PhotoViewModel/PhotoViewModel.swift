//
//  PhotoViewModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import Foundation
import Combine

protocol PhotoViewModable: AnyObject {
    var title: CurrentValueSubject<String, Never> { get }
    var photo: CurrentValueSubject<Data, Never> { get }
    var currentIndex: CurrentValueSubject<Int, Never> { get }
    var cellCount: CurrentValueSubject<Int, Never> { get }
    func getCellCount() -> Int
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void)
    func setNewIndex(_ newIndex: Int)
}

class PhotoViewModel: PhotoViewModable {
    
    private(set) var title: CurrentValueSubject<String, Never> = .init("")
    private(set) var photo: CurrentValueSubject<Data, Never> = .init(Images.placeholder.pngData()!)
    private var photoID: UUID = .init()
    private(set) var currentIndex: CurrentValueSubject<Int, Never> = .init(0)
    private(set) var cellCount: CurrentValueSubject<Int, Never> = .init(0)
    
    private var bindings: Set<AnyCancellable> = .init()
    private let model: PhotoModable
    
    init(token: String, currentindex: Int) {
        model = PhotoModel.init(token: token)
        bind()
        model.initialize()
        self.currentIndex.send(currentindex)
    }
    
    func setNewIndex(_ newIndex: Int) {
        currentIndex.send(newIndex)
    }
    
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void) {
        model.getPhoto(with: .small, for: index, with: id, completion: completion)
    }
    
    func getCellCount() -> Int {
        cellCount.value
    }
    
    private func bind() {
        currentIndex
            .sink { [unowned self] _ in
                self.updateTitle()
            }
            .store(in: &bindings)
        
        currentIndex
            .sink { [unowned self] _ in
                self.updatePhoto()
            }
            .store(in: &bindings)
        
        model.photosCount
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] count in
                self.cellCount.send(count)
            }
            .store(in: &bindings)
        
        model.initializationDone
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.updateTitle()
                self.updatePhoto()
            }
            .store(in: &bindings)
    }
    
    private func updateTitle() {
        title.send(model.getTitle(for: currentIndex.value)?.convertToTime() ?? "")
    }
    
    private func updatePhoto() {
        photoID = UUID()
        self.photo.send(Images.placeholder.pngData()!)
        model.getPhoto(with: .large, for: currentIndex.value, with: photoID) { [weak self] data, id in
            guard let self = self,
                  let data = data,
                  self.photoID == id else {
                      return
                  }
            self.photo.send(data)
        }
    }
}
