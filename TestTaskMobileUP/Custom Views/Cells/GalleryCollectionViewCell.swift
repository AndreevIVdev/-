//
//  GalleryCollectionViewCell.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//


import UIKit

// MARK: - Class GalleryCollectionViewCell
final class GalleryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    private(set) var id: UUID = .init()
    
    // MARK: - Private Properties
    private let imageView: TTImageView = .init()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.startLoadingAnimation()
        id = UUID()
    }
    
    // MARK: - Public Methods
    func set(by data: Data?) {
        DispatchQueue.main.async {
            self.imageView.setImage(data)
        }
    }
    
    // MARK: - Private Methods
    private func configureCell() {
        contentView.addSubViews(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
