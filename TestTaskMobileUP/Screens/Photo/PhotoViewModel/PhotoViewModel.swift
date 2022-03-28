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
    private(set) var cellCount: CurrentValueSubject<Int, Never> = .init(0)
    
    private var bindings: Set<AnyCancellable> = .init()
    private let model: PhotoModel

    init(token: String, currentindex: Int) {
        model = .init(token: token)
        self.currentIndex.send(currentindex)
        bind()
    }
    
    func setNewIndex(_ newIndex: Int) {
        currentIndex.send(newIndex)
    }
    
    func getCell(for index: Int, completion: @escaping (Data?, Int) -> Void) {
        model.getPhoto(for: index, completion: completion)
    }
    
    func getCellCount() -> Int {
        cellCount.value
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
        
        model.photosCount
            .sink { [unowned self] count in
                self.cellCount.value = count
            }
            .store(in: &bindings)
        
        model.initializationDone
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
        model.getPhoto(for: currentIndex.value) { [weak self] data, _ in
            guard let self = self else { return }
            self.photo.send(data ?? Images.placeholder.pngData()!)
        }
    }
}
