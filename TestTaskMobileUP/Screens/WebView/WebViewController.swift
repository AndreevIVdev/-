//
//  WebViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit
import WebKit

// MARK: - Class WebViewController
/// Remote login screen
class WebViewController: UIViewController {

    // MARK: - Private Properties
    /// View to show external web page
    private let webView: WKWebView = .init()
    /// Shows downloading animation
    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)
    /// Closes the modal screen with tap
    private let closeButton: UIButton = .init()
    /// Result returning closure
    private let completed: (Result<String, Error>) -> Void?
    /// URL for remote Web page
    private let url: URL
    
    // MARK: - Initializers
    init(url: URL, completed: @escaping (Result<String, Error>) -> Void) {
        self.completed = completed
        self.url = url
        super.init(nibName: nil, bundle: nil)
        print("\(String(describing: type(of: self))) INIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Override Methods
    /// Creates the view that the controller manages
    override func loadView() {
        super.loadView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
        configureNavigationItem()
        startLoading()
    }
    
    // MARK: - Private Methods
    /// Configures view to show external login Web page
    private func configureWebView() {
        webView.navigationDelegate = self
        webView.addSubViews(activityIndicator, closeButton)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
        activityIndicator.hidesWhenStopped = true
    }
    
    /// Configures navigation item and screen close button
    private func configureNavigationItem() {
        closeButton.setImage(Images.xmark, for: .normal)
        closeButton.tintColor = .black
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: webView.topAnchor)
        ])
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    /// Starts downloading of authorization Web page
    private func startLoading() {
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
        activityIndicator.startAnimating()
    }
    
    /// Handles close butto tap
    @objc private func closeButtonTapped() {
        if let presentationController = presentationController {
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        }
        dismiss(animated: true)
    }
}

// MARK: - Extension WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    
    /// Handles current state of the Web view
    /// - Parameters:
    ///   - webView: current web view
    ///   - navigationAction: An object that contains information about an action that causes navigation to occur
    ///   - decisionHandler: Constants that indicate whether to allow or cancel navigation to a webpage
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if let token = VKClient.getTokenFrom(url: url) {
                dismiss(animated: true, completion: nil)
                decisionHandler(.cancel)
                completed(.success(token))
                return
            } else if VKClient.isAccessDenied(url: url) {
                dismiss(animated: true, completion: nil)
                decisionHandler(.cancel)
                completed(.failure(TTError.accessDenied))
                return
            }
        }
        decisionHandler(.allow)
    }
    
    /// Handles web page downloading finish
    /// - Parameters:
    ///   - webView: current webview
    ///   - navigation: An object that tracks the loading progress of a webpage
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    /// Handles posssible error during webpage downloading
    /// - Parameters:
    ///   - webView: current webview
    ///   - navigation: An object that tracks the loading progress of a webpage
    ///   - error: A type representing an error value that can be thrown
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        completed(.failure(error))
        dismiss(animated: true, completion: nil)
    }
}
