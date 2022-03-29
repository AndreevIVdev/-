//
//  GalleryViewModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 29.03.2022.
//

import Foundation
import Combine

// MARK: - Protocol GalleryViewModable
protocol GalleryViewModable: AnyObject {
    var cellCount: CurrentValueSubject<Int, Never> { get }
    var error: PassthroughSubject<Error, Never> { get }
    func getCellCount() -> Int
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void)
}

// MARK: - Class GalleryViewModel
class GalleryViewModel: GalleryViewModable {
    
    // MARK: - Publishers
    private(set) var cellCount: CurrentValueSubject<Int, Never> = .init(0)
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    // MARK: - Private Properties
    private let model: GalleryModable
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
    func getCell(for index: Int, with id: UUID, completion: @escaping (Data?, UUID) -> Void) {
        model.getPhoto(with: .medium, for: index, with: id, completion: completion)
    }
    
    func getCellCount() -> Int {
        cellCount.value
    }
    
    // MARK: - Private Methods
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
