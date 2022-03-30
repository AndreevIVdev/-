//
//  PhotoViewModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import Foundation
import Combine

// MARK: - Protocol FullScreenPhotoViewModable
/// Protocol describing necessary functions of fullscreen Photo View Model instance
protocol FullScreenPhotoViewModable: AnyObject {
    var title: CurrentValueSubject<String, Never> { get }
    var photo: CurrentValueSubject<Data?, Never> { get }
    var currentIndex: CurrentValueSubject<Int, Never> { get }
    var cellCount: CurrentValueSubject<Int, Never> { get }
    var error: PassthroughSubject<Error, Never> { get }
    func getCellCount() -> Int
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void)
    func setNewIndex(_ newIndex: Int)
}

// MARK: - Class FullScreenPhotoViewModel
class FullScreenPhotoViewModel: FullScreenPhotoViewModable {
    
    // MARK: - Publishers
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    private(set) var title: CurrentValueSubject<String, Never> = .init("")
    private(set) var photo: CurrentValueSubject<Data?, Never> = .init(Data())
    private(set) var currentIndex: CurrentValueSubject<Int, Never> = .init(0)
    private(set) var cellCount: CurrentValueSubject<Int, Never> = .init(0)
    
    // MARK: - Private Properties
    private let model: PhotoModable
    /// Subscriptions storage
    private var bindings: Set<AnyCancellable> = .init()
    /// Uniq id for fullscreen Photo
    private var photoID: UUID = .init()
    
    // MARK: - Initializers
    init(token: String, currentindex: Int) {
        model = PhotoModel.init(token: token)
        bindViewModelToViewModel()
        bindViewModelToModel()
        model.initialize()
        self.currentIndex.send(currentindex)
        print("\(String(describing: type(of: self))) INIT")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Public Methods
    /// Updates selected photo index
    /// - Parameter newIndex: new index
    func setNewIndex(_ newIndex: Int) {
        currentIndex.send(newIndex)
    }
    
    /// Gets data for seelcted cell
    /// - Parameters:
    ///   - index: cell position
    ///   - id: uniq cell id
    ///   - completion: result in completion block
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void) {
        model.getPhoto(size: .small, for: index, and: id, completion: completion)
    }
    
    /// Returns count of cells
    /// - Returns: result
    func getCellCount() -> Int {
        cellCount.value
    }
    
    
    // MARK: - Private Methods
    /// Initializes reactive connections
    private func bindViewModelToViewModel() {
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
    }
    
    /// Initializes reactive connections
    private func bindViewModelToModel() {
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
                self.error.send(error)
                localErrorHandling(error)
            }
            .store(in: &bindings)
    }
    
    /// Updates title on the screen
    private func updateTitle() {
        title.send(model.getTitle(for: currentIndex.value)?.convertToTime() ?? "")
    }
    
    /// Updates photo
    private func updatePhoto() {
        photoID = UUID()
        self.photo.send(nil)
        model.getPhoto(size: .large, for: currentIndex.value, and: photoID) { [weak self] data, id in
            guard let self = self,
                  let data = data,
                  self.photoID == id else {
                      return
                  }
            self.photo.send(data)
        }
    }
    
    /// Handles occurring error locally
    /// - Parameter error: current error
    private func localErrorHandling(_ error: Error) {
        
        if let error = error as? TTError {
            switch error {
            case .noData, .urlError, .invalidResponse, .internalError, .serverProblem:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.model.initialize()
                }
            default:
                print()
            }
        }
    }
}
