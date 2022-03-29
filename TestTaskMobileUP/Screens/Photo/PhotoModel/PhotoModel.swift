//
//  PhotoModel.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import Foundation
import Combine

// MARK: - Protocol PhotoModable
/// Protocol describing necessary functions of Photo Model instance
protocol PhotoModable: AnyObject {
    /// Publisher that sends photo count in album
    var photosCount: PassthroughSubject<Int, Never> { get }
    /// Publisher that sends initialization completion notification
    var initializationDone: PassthroughSubject<Void, Never> { get }
    /// Publisher that sends occurring error
    var error: PassthroughSubject<Error, Never> { get }
    /// Returns data for photo at given position
    func getPhoto(size: PhotoSize, for index: Int, and id: UUID, completion: @escaping (Data?, UUID) -> Void)
    /// Returns title for photo at given position
    func getTitle(for index: Int) -> Int?
    /// Starts model initialization
    func initialize()
}

// MARK: - Class PhotoModel 😀
/// Photo gallery model
class PhotoModel: PhotoModable {
    
    // MARK: - Publishers
    /// Publisher that sends photo count in album
    private(set) var photosCount: PassthroughSubject<Int, Never> = .init()
    /// Publisher that sends initialization completion notification
    private(set) var initializationDone: PassthroughSubject<Void, Never> = .init()
    /// Publisher that sends occurring error
    private(set) var error: PassthroughSubject<Error, Never> = .init()
    
    // MARK: - Private Properties
    /// Access token for current session
    private let token: String
    /// Datasource for photos with small resolution
    private var smallPictures: [Data?] = []
    /// Datasource for photos with normal resolution
    private var mediumPictures: [Data?] = []
    /// Datasource for hight resolution photos
    private var bigPictures: [Data?] = []
    /// Subscriptions storage
    private var bindings: Set<AnyCancellable> = .init()
    /// Info source for photos
    private var album: Album?
    
    // MARK: - Initializers
    init(token: String) {
        self.token = token
        print("\(String(describing: type(of: self))) INIT")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Public Methods
    /// Starts model initialization
    func initialize() {
        loadAlbum { [weak self] in
            guard let self = self,
                  let album = self.album else { return }
            self.smallPictures = .init(repeating: nil, count: album.count)
            self.mediumPictures = .init(repeating: nil, count: album.count)
            self.bigPictures = .init(repeating: nil, count: album.count)
            self.photosCount.send(album.count)
            self.initializationDone.send()
        }
    }
    
    /// Returns data for photo at given position
    func getPhoto(size: PhotoSize, for index: Int, and id: UUID, completion: @escaping (Data?, UUID) -> Void) {
        guard let album = album,
              index < album.count else {
            completion(nil, id)
            return
        }
        
        var dataSource: [Data?] = []
        switch size {
        case .small:
            dataSource = smallPictures
        case .medium:
            dataSource = mediumPictures
        case .large:
            dataSource = bigPictures
        }
        
        if let data = dataSource[index] {
            completion(data, id)
            return
        }
        
        loadPhoto(with: size, index: index) { [weak self] data in
            guard let self = self,
                  let data = data else {
                completion(Images.placeholder.pngData(), id)
                return
            }
            self.savePhoto(data, with: size, and: index)
            completion(data, id)
        }
    }
    
    /// Returns title for photo at given position
    func getTitle(for index: Int) -> Int? {
        guard let album = album,
              index < album.count  else { return nil }
        
        return album.photos[index].date
    }
    
    // MARK: - Private Methods
    /// Loads info source to get photos
    /// - Parameter completed: calles when album is fully loaded
    private func loadAlbum(completed: @escaping () -> Void) {
        guard let url = VKClient.photosURL(with: self.token) else { return }
        NetworkManager.shared.fetchData(from: url) { [weak self] result in
            defer {
                completed()
            }
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    self.album = try JSONDecoder().decode(VKResponse.self, from: data).album
                } catch {
                    self.error.send(TTError.invalidResponse)
                }
            case .failure(let error):
                self.error.send(error)
            }
        }
    }
    
    /// Loads photo from internet
    /// - Parameters:
    ///   - size: Needed resolution size
    ///   - index: Position of photo
    ///   - completion: result in completion block
    private func loadPhoto(with size: PhotoSize, index: Int, completion: @escaping (Data?) -> Void) {
        guard let album = album else {
            completion(nil)
            return
        }
        var photoSize: Size?
        let screenWidth = Int(ScreenSize.width)
        switch size {
        case .small:
            photoSize = album.photos[index].sizes.min(by: { $0.width < $1.width })
        case .medium:
            photoSize = album.photos[index].sizes.min {
                abs($0.width - screenWidth * 2 / 3) < abs($1.width - screenWidth * 2 / 3)
            }
        case .large:
            photoSize = album.photos[index].sizes.min(by: { abs($0.width - screenWidth) < abs($1.width - screenWidth) })
        }
        
        guard let url = URL(string: photoSize!.url) else {
            completion(nil)
            return
        }
        
        NetworkManager.shared.fetchDataWithOutErrorHandling(from: url) { data in
            completion(data)
        }
    }
    
    /// Saves photo locally
    /// - Parameters:
    ///   - photo: Photo to be saved
    ///   - size: Photos resolution template
    ///   - index: Photo position
    private func savePhoto(_ photo: Data, with size: PhotoSize, and index: Int) {
        switch size {
            
        case .small:
            smallPictures[index] = photo
        case .medium:
            mediumPictures[index] = photo
        case .large:
            bigPictures[index] = photo
        }
    }
}

// MARK: - Enum PhotoSize
/// Templates for photo resolution
enum PhotoSize {
    case small
    case medium
    case large
}
