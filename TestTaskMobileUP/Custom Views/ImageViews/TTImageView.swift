//
//  TTImageView.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 28.03.2022.
//

import UIKit

class TTImageView: UIImageView {
    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)
    
    init() {
        super.init(frame: .zero)
        addSubViews(activityIndicator)
        configureActivityIndicator()
        image = Images.placeholder
        startLoadingAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
    }
    
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
