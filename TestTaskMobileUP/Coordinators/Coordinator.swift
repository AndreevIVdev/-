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
        let blankViewController: AuthViewController = .init {}
        window.rootViewController = blankViewController
    }
    
    func start() {
        authManager.$state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                self.handleState(state: state)
            }
            .store(in: &bindings)
        
        authManager.error
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] error in
                self.handleError(error: error)
            }
            .store(in: &bindings)
        
        authManager.isLoggedIn()
    }
    
    private func authButtonTapped() {
        authManager.isLoggedIn { isLogged in
            guard isLogged == false else { return }
            DispatchQueue.main.async {
                guard let request = VKClient.loginRequest() else { return }
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
        }
    }
    
    private func handleSignOut() {
        authManager.logoutFromCurrentAccount()
    }
    
    private func handleGalleryTap(index: Int) {
        guard let token = authManager.getToken() else { return }
        navigationController.pushViewController(
            PhotoViewController(
                token: token,
                initialIndex: index
            ),
            animated: true
        )
    }
        
    private func handleState(state: AuthState) {
        switch state {
        case .authorized:
            guard let token = authManager.getToken() else { return }
            self.navigationController.viewControllers = [
                GalleryViewController(
                    token: token,
                    signOut: handleSignOut,
                    choosen: handleGalleryTap(index:)
                )
            ]
            self.window.rootViewController = self.navigationController
        case .undefined, .unauthorized:
            self.window.rootViewController = AuthViewController(signIn: self.authButtonTapped)
        }
    }

    
    private func handleError(error: Error) {
        if let error = error as? TTError {
            switch error {
            case .accessDenied, .invalidToken:
                self.window.rootViewController?.showAlert(title: "Error", message: error.rawValue) {
                    self.authManager.logoutFromCurrentAccount()
                }
            case .noData, .urlError, .invalidResponse, .internalError, .serverProblem:
                self.window.rootViewController?.showAlert(title: "Error", message: error.rawValue) {
                    self.authManager.undefine()
                }
            }
        } else {
            self.window.rootViewController?.showAlert(title: "Error", message: error.localizedDescription) {
                self.authManager.undefine()
            }
        }
    }
}
