//
//  UIImageView + Ext.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import UIKit

extension UIImageView {
    func enableZooming() {
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UIPinchGestureRecognizer(
                target: self,
                action: #selector(startZooming)
            )
        )
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    func updateOn(url: URL) {
        NetworkingManager.shared.fetchDataWithOutErrorHandling(from: url) { [weak self] data in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
