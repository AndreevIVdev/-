//
//  PhotoView.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import UIKit
import Combine

class PhotoViewController: UIViewController {
    
    private let photoImageView: UIImageView = .init()
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UIHelper.createHorizontalFlowLayout()
    )
    private let checkmarkImageView: UIImageView = .init(
        image: .init(
            systemName: "checkmark.circle.fill"
        )
    )
    
    private let viewModel: PhotoViewModel
    
    private var bindings: Set<AnyCancellable> = .init()
    
    init(token: String, initialIndex: Int) {
        viewModel = .init(
            token: token,
            currentindex: initialIndex
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configurePhotoImageView()
        configureSuccsessImageView()
        configureBindings()
    }
    
    private func configureCollectionView() {
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.description()
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.width / 6),
            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed
                ? -Design.padding : -Design.bottomPadding
            )
        ])
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        view.addSubViews(photoImageView, checkmarkImageView, collectionView)
        navigationItem.rightBarButtonItem = .init(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(share)
        )
    }
    
    private func configurePhotoImageView() {
        photoImageView.frame.size.width = view.frame.width
        photoImageView.frame.size.height = view.frame.width
        photoImageView.frame.origin.x = 0
        photoImageView.frame.origin.y = (view.frame.height - view.frame.width) / 2
        
        photoImageView.image = Images.placeholder
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.enableZooming()
    }
    
    private func configureSuccsessImageView() {
        checkmarkImageView.frame.size.width = view.frame.width
        checkmarkImageView.frame.size.height = view.frame.width
        checkmarkImageView.frame.origin.x = 0
        checkmarkImageView.frame.origin.y = (view.frame.height - view.frame.width) / 2
        
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.alpha = 0
    }
    
    private func configureBindings() {
        viewModel.photo
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                guard let image = UIImage(data: data) else {
                          self.photoImageView.image = Images.placeholder
                          return
                      }
                self.photoImageView.image = image
            }
            .store(in: &bindings)
        
        viewModel.title
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] title in
                self.title = title
            }
            .store(in: &bindings)
        
        viewModel.cellCount
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.collectionView.reloadData()
            }
            .store(in: &bindings)
    }
    
    @objc private func share() {
        let shareController: UIActivityViewController = .init(
            activityItems: [photoImageView.image ?? Images.placeholder],
            applicationActivities: nil
        )
        
        shareController.completionWithItemsHandler = { activity, success, _, error in
            if !success {
                return
            }
            
            guard let activity = activity else { return }
            
            switch activity {
            case .saveToCameraRoll:
                if let error = error {
                    print(error)
                } else {
                    self.checkmarkImageView.alpha = 0.8
                    UIView.animate(withDuration: 0.3) {
                        self.checkmarkImageView.transform = .init(scaleX: 0.7, y: 0.7)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.4) {
                            self.checkmarkImageView.transform = .init(scaleX: 1, y: 1)
                        } completion: { _ in
                            UIView.animate(withDuration: 0.2, delay: 1) {
                                self.checkmarkImageView.alpha = 0
                            }
                        }
                    }
                }
            default:
                return
            }
        }
        present(shareController, animated: true, completion: nil)
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getCellCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryCollectionViewCell.description(),
            for: indexPath) as! GalleryCollectionViewCell
        viewModel.getCell(for: indexPath.row) { data, index in
            guard indexPath.row == index else {
                return
            }
            cell.set(by: data)
        }
        return cell
    }
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setNewIndex(indexPath.row)
    }
}
