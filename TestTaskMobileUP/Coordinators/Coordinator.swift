//
//  Coordinator.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//


import UIKit
import Combine

// MARK: - Class Coordinator
/// Coordinator for error handling and navigation
final class Coordinator: NSObject {
    
    // MARK: - Private Properties
    /// Main app window
    private let window: UIWindow
    /// Navigation controller for main appflow
    private let photosNavigationController: UINavigationController = .init()
    /// Authorisation and login manager
    private let authManager: AuthManager = .shared
    /// Subscriptions storage
    private var bindings: Set<AnyCancellable> = .init()
    
    // MARK: - Initializers
    init(for window: UIWindow) {
        self.window = window
        super.init()
        setupBindingsSelfToSelf()
        print("\(String(describing: type(of: self))) INIT")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Public Methods
    /// Ыtart of the application under the control of the coordinator
    func start() {
        let authViewController: AuthViewController = .init()
        authViewController.delegate = self
        window.rootViewController = authViewController
        window.makeKeyAndVisible()
        authManager.isLoggedIn()
    }
    
    // MARK: - Private Methods
    /// Initializes reactive connections
    private func setupBindingsSelfToSelf() {
        authManager.$state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                self.handleState(state)
            }
            .store(in: &bindings)
        
        authManager.error
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] error in
                self.handleError(error)
            }
            .store(in: &bindings)
    }
    
    /// Handles the current state of the application
    /// - Parameter state: current application state
    private func handleState(_ state: AuthState) {
        switch state {
        case .authorized:
            guard let token = authManager.getToken() else { return }
            let galleryViewController: GalleryViewController = .init(token: token)
            galleryViewController.delegate = self
            photosNavigationController.viewControllers = [
                galleryViewController
            ]
            window.rootViewController = photosNavigationController
        case .undefined, .unauthorized:
            if window.rootViewController is AuthViewController {
                return
            }
            let authViewController: AuthViewController = .init()
            authViewController.delegate = self
            window.rootViewController = authViewController
            photosNavigationController.viewControllers = []
        }
    }
    
    /// Handles errors that occur while the application is running
    /// - Parameter error: current error
    private func handleError(_ error: Error) {
        if let error = error as? TTError {
            switch error {
            case .accessDenied, .invalidToken:
                self.window.rootViewController?.showAlert(
                    title: "Error".localized(),
                    message: error.rawValue.localized()
                ) {
                    self.authManager.logoutFromCurrentAccount()
                }
            case .noData, .urlError, .invalidResponse, .internalError, .serverProblem, .unsuccessfulLogin:
                self.window.rootViewController?.showAlert(
                    title: "Error".localized(),
                    message: error.rawValue.localized()
                )
            }
        } else {
            self.window.rootViewController?.showAlert(
                title: "Error".localized(),
                message: error.localizedDescription
            ) {
                self.authManager.undefine()
            }
        }
    }
}

// MARK: - Extension UIAdaptivePresentationControllerDelegate
extension Coordinator: UIAdaptivePresentationControllerDelegate {
    
    /// Handles hiding the modal controller
    /// - Parameter presentationController: presentation manager
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        authManager.isLoggedIn { [weak self] isLogged in
            guard let self = self,
                  isLogged == false else { return }
            DispatchQueue.main.async {
                self.handleError(TTError.unsuccessfulLogin)
            }
        }
    }
}

// MARK: - Extension AuthViewControllerDelegate
extension Coordinator: AuthViewControllerDelegate {
    
    /// Handles the login button click on the login screen
    func signInButtonTapped() {
        authManager.isLoggedIn { isLoggedIn in
            guard isLoggedIn == false else { return }
            DispatchQueue.main.async {
                guard let url = VKClient.loginURL() else { return }
                let viewController: WebViewController = .init(url: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let token):
                        self.authManager.save(token)
                    case .failure(let error):
                        self.handleError(error)
                    }
                }
                viewController.modalPresentationStyle = .popover
                viewController.presentationController?.delegate = self
                self.window.rootViewController?.present(viewController, animated: true)
            }
        }
    }
}

// MARK: - Extension GalleryViewControllerDelegate
extension Coordinator: GalleryViewControllerDelegate {
    
    /// Handles the sign out button click on the gallery screen
    func signOutButtonTapped() {
        authManager.logoutFromCurrentAccount()
    }
    
    /// Handles the photo tap on the gallery screen
    func didSelectItemAt(_ index: Int) {
        guard let token = authManager.getToken() else { return }
        let photoViewController = FullScreenPhotoViewController(
            token: token,
            initialIndex: index
        )
        
        photoViewController.error
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] error in
                self.handleError(error)
            }
            .store(in: &bindings)
        
        photosNavigationController.pushViewController(
            photoViewController,
            animated: true
        )
    }
}
