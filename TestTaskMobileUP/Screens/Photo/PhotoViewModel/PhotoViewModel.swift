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
    var showAlert: PassthroughSubject<String, Never> { get }
    var error: PassthroughSubject<Error, Never> { get }
    func getCellCount() -> Int
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void)
    func setNewIndex(_ newIndex: Int)
}

class PhotoViewModel: PhotoViewModable {
    
    private(set) var title: CurrentValueSubject<String, Never> = .init("")
    private(set) var photo: CurrentValueSubject<Data, Never> = .init(Data())
    private(set) var currentIndex: CurrentValueSubject<Int, Never> = .init(0)
    private(set) var cellCount: CurrentValueSubject<Int, Never> = .init(0)
    private(set) var showAlert: PassthroughSubject<String, Never> = .init()
    var error: PassthroughSubject<Error, Never> = .init()
    private var bindings: Set<AnyCancellable> = .init()
    private let model: PhotoModable
    
    private var photoID: UUID = .init()
    
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
            .sink { [unowned self] count in
                self.cellCount.send(count)
            }
            .store(in: &bindings)
        
        model.initializationDone
            .sink { [unowned self] _ in
                self.updateTitle()
                self.updatePhoto()
            }
            .store(in: &bindings)
        
        model.error
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] error in
                self.handleError(error)
            }
            .store(in: &bindings)
    }
    
    private func updateTitle() {
        title.send(model.getTitle(for: currentIndex.value)?.convertToTime() ?? "")
    }
    
    private func updatePhoto() {
        photoID = UUID()
        self.photo.send(Data())
        model.getPhoto(with: .large, for: currentIndex.value, with: photoID) { [weak self] data, id in
            guard let self = self,
                  let data = data,
                  self.photoID == id else {
                      return
                  }
            self.photo.send(data)
        }
    }
    
    private func handleError(_ error: Error) {
        if let error = error as? TTError {
            switch error {
            case .accessDenied, .invalidToken:
                self.error.send(error)
            case .noData, .urlError, .invalidResponse, .internalError, .serverProblem:
                showAlert.send(error.rawValue)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.model.initialize()
                }
            }
        } else {
            showAlert.send(error.localizedDescription)
        }
    }
}
