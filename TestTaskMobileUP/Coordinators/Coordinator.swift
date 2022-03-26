//
//  Coordinator.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//


import UIKit


final class Coordinator {
    
    private let window: UIWindow
    
    init(
        window: UIWindow
    ) {
        self.window = window
    }
    
    func start() {
        window.rootViewController = AuthViewController(signIn: authButtonTapped)
    }
    
    private func authButtonTapped() {
        let viewController: WebViewController = .init { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let token):
                print(token)
            case .failure(let error):
                print(error)
            }
        }
        viewController.modalPresentationStyle = .popover
        DispatchQueue.main.async {
            self.window.rootViewController?.present(viewController, animated: true)
        }
    }
}
