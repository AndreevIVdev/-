//
//  Coordinator.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//


import UIKit
import Combine

final class Coordinator {
    
    private let window: UIWindow
    private let navigationController: UINavigationController = .init()
    private let authManager: AuthManager = .shared
    
    private var bindings: Set<AnyCancellable> = .init()
    
    init(
        window: UIWindow
    ) {
        self.window = window
    }
    
    func start() {
        authManager.$state
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .authorized:
                    guard let token = self.authManager.getToken() else { return }
                    self.navigationController.viewControllers = [
                        GalleryViewController(
                            token: token,
                            signOut: self.handleSignOut,
                            choosen: self.handleGalleryTap(index:dataSource:)
                        )
                    ]
                    self.window.rootViewController = self.navigationController
                case .unauthorized:
                    self.window.rootViewController = AuthViewController(signIn: self.authButtonTapped)
                case .error:
                    print("error")
                }
            }
            .store(in: &bindings)
    }
    
    private func authButtonTapped() {
        guard let request = VKClient.login() else { return }
        let viewController: WebViewController = .init(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.authManager.save(token)
            case .failure(let error):
                print(error)
            }
        }
        viewController.modalPresentationStyle = .popover
        DispatchQueue.main.async {
            self.window.rootViewController?.present(viewController, animated: true)
        }
    }
    
    private func handleSignOut() {
        authManager.logoutFromCurrentAccount()
    }
    
    private func handleGalleryTap(index: Int, dataSource: [Photo]) {
        navigationController.pushViewController(
            PhotoViewController(
                initialIndex: index,
                datasource: dataSource
            ),
            animated: true
        )
    }
}
