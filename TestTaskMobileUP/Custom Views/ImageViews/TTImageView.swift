//
//  TTImageView.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 28.03.2022.
//

import UIKit

// MARK: - Class TTImageView
class TTImageView: UIImageView {
    
    // MARK: - Private Properties
    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        addSubViews(activityIndicator)
        configureActivityIndicator()
        startLoadingAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
    }
    
    func setImage(_ data: Data?) {
        var image: UIImage?
        if let data = data {
            image = UIImage(data: data)
        }
        UIView.transition(
            with: self,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.image = image },
            completion: nil
        )
        image == nil ? startLoadingAnimation() : stopLoadingAnimation()
    }
    
    // MARK: - Private Methods
    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
