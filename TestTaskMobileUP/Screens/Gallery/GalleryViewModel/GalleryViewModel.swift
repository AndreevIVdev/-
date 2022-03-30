//
//  GalleryViewModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 29.03.2022.
//

import Foundation
import Combine

// MARK: - Protocol GalleryViewModable
/// Protocol describing necessary functions of Gallery View Model instance
protocol GalleryViewModable: AnyObject {
    
    /// Publisher that sends cell count
    var cellCount: CurrentValueSubject<Int, Never> { get }
    /// Publisher that sends occuring errors
    var error: PassthroughSubject<Error, Never> { get }
    /// Returns cell count
    func getCellCount() -> Int
    /// Returns propper data for cell
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void)
}

// MARK: - Class GalleryViewModel
/// Photo gallery view model
final class GalleryViewModel: GalleryViewModable {
    
    // MARK: - Publishers
    /// Publisher that sends cell count
    private(set) var cellCount: CurrentValueSubject<Int, Never> = .init(0)
    /// Publisher that sends occuring errors
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    // MARK: - Private Properties
    /// Handles data and network calls
    private let model: GalleryModable
    /// Subscriptions storage
    private var bindings: Set<AnyCancellable> = .init()
    
    // MARK: - Initializers
    init(token: String) {
        model = GalleryModel.init(token: token)
        bindModelToViewMOdel()
        model.initialize()
        print("\(String(describing: type(of: self))) INIT")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Public Methods
    /// Returns cell count
    func getCellCount() -> Int {
        cellCount.value
    }
    
    /// Returns propper data for cell
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void) {
        model.getPhoto(size: .medium, for: index, and: id, completion: completion)
    }
    
    // MARK: - Private Methods
    /// Initializes reactive connections
    private func bindModelToViewMOdel() {
        model.photosCount
            .sink { [unowned self] count in
                self.cellCount.send(count)
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
    
    /// Handles occurring errors locally
    /// - Parameter error: Cccurred error
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
