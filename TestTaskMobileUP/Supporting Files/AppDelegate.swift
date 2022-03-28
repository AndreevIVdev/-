//
//  AppDelegate.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var coordinator: Coordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        UINavigationBar.appearance().tintColor = .label
        coordinator = .init(window: window!)
        coordinator?.start()
        URLCache().removeAllCachedResponses()
        window?.makeKeyAndVisible()
        return true
    }
}
