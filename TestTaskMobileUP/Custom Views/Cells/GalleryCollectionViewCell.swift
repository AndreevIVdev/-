//
//  GalleryCollectionViewCell.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//


import UIKit

// MARK: - Class GalleryCollectionViewCell
/// Cell with image and uniq id
final class GalleryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    /// Uniq cell id
    private(set) var id: UUID = .init()
    
    // MARK: - Private Properties
    /// Container for image
    private let imageView: LoadingImageView = .init()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    /// Prepares cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.startLoadingAnimation()
        id = UUID()
    }
    
    // MARK: - Public Methods
    /// Initializes cell with given data
    /// - Parameter data: image in data format
    func set(by data: Data?) {
        DispatchQueue.main.async {
            self.imageView.setImage(data)
        }
    }
    
    // MARK: - Private Methods
    /// Primary cell configuration
    private func configureCell() {
        contentView.addSubViews(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
