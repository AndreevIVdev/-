//
//  WebViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit
import WebKit

// MARK: - Class WebViewController
class WebViewController: UIViewController {

    // MARK: - Private Properties
    private let webView: WKWebView = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)
    private let closeButton: UIButton = .init()
    private let completed: (Result<String, Error>) -> Void?
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
    
    private func startLoading() {
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
        activityIndicator.startAnimating()
    }
    
    @objc private func closeButtonTapped() {
        if let presentationController = presentationController {
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        }
        dismiss(animated: true)
    }
}

// MARK: - Extension WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {

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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        completed(.failure(error))
        dismiss(animated: true, completion: nil)
    }
}
