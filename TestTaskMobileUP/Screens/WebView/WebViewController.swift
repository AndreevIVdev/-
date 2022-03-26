//
//  WebViewController.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    private var webView: WKWebView = .init()
    private var completed: (Result<String, Error>) -> Void?
    
    init(completed: @escaping (Result<String, Error>) -> Void) {
        self.completed = completed
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
    }
    
    private func startLoading() {
        webView.load(VKClient.login())
    }
}

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

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completed(.failure(error))
        dismiss(animated: true, completion: nil)
    }
}
