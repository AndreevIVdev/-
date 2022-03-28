//
//  GalleryCollectionViewCell.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//


import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {
    
    private let imageView: TTImageView = .init()
    private(set) var id: UUID = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = Images.placeholder
        imageView.startLoadingAnimation()
        id = UUID()
    }
    
    func set(by photo: Photo) {
        guard let url = URL(string: photo.sizes[4].url) else { return }
        NetworkingManager.shared.fetchDataWithOutErrorHandling(from: url) { [weak self, id] data in
            guard let self = self,
                  let data = data,
                  self.id == id
            else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func set(by data: Data?) {
        guard let data = data,
              let image = UIImage(data: data) else { return }
        DispatchQueue.main.async {
            self.imageView.setImage(image)
            self.imageView.stopLoadingAnimation()
        }
    }
    
    private func configureCell() {
        contentView.addSubViews(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
