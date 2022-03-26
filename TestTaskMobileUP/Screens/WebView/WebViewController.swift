//
//  WebViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    private let webView: WKWebView = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)
    
    private let completed: (Result<String, Error>) -> Void?
    private let request: URLRequest
    
    
    init(request: URLRequest, completed: @escaping (Result<String, Error>) -> Void) {
        self.completed = completed
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
        startLoading()
    }
    
    private func configureWebView() {
        webView.navigationDelegate = self
        webView.addSubViews(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
        activityIndicator.hidesWhenStopped = true
    }
    
    private func startLoading() {
        webView.load(request)
        activityIndicator.startAnimating()
    }
}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if let token = URLLogic.getTokenFrom(url: url) {
                dismiss(animated: true, completion: nil)
                decisionHandler(.cancel)
                completed(.success(token))
                return
            } else if URLLogic.isAccessDenied(url: url) {
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
