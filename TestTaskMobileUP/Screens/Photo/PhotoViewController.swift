//
//  PhotoViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import UIKit
import Combine

class PhotoViewController: UIViewController {
    
    private let photoImageView: UIImageView = .init()
    private let successImageView: UIImageView = .init(
        image: .init(
            systemName: "checkmark.circle.fill"
        )
    )
    
    @Published private var currentindex: Int
    private var bindings: Set<AnyCancellable> = .init()
    
    private let datasource: [Photo]
    
    init(initialIndex: Int, datasource: [Photo]) {
        currentindex = initialIndex
        self.datasource = datasource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configurePhotoImageView()
        configureSuccsessImageView()
        configureBindings()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        view.addSubViews(photoImageView, successImageView)
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
        successImageView.frame.size.width = view.frame.width
        successImageView.frame.size.height = view.frame.width
        successImageView.frame.origin.x = 0
        successImageView.frame.origin.y = (view.frame.height - view.frame.width) / 2
        
        successImageView.tintColor = .systemGreen
        successImageView.alpha = 0
    }
    
    private func configureBindings() {
        $currentindex.sink { [weak self] index in
            guard let self = self,
                  index < self.datasource.count,
                  let url = URL(string: self.datasource[index].sizes[4].url) else {
                      return
                  }
            DispatchQueue.global().async {
                self.photoImageView.updateOn(url: url)
            }
            self.title = self.datasource[index].date.convertToTime()
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
                    self.successImageView.alpha = 0.8
                    UIView.animate(withDuration: 0.3) {
                        self.successImageView.transform = .init(scaleX: 0.7, y: 0.7)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.4) {
                            self.successImageView.transform = .init(scaleX: 1, y: 1)
                        } completion: { _ in
                            UIView.animate(withDuration: 0.2, delay: 1) {
                                self.successImageView.alpha = 0
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
