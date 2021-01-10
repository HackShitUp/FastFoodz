//
//  SceneDelegate.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UISceneDelegate {
    
    // MARK: - Class Vars

    // MARK: - UIWindow
    var window: UIWindow?
    
    /// Gets and returns the appropriate UIScene's UIWindow's UIEdgeInsets for the device's safe area, if there's any
    static var safeAreaInsets: UIEdgeInsets {
        get {
            return ((UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).first as? UIWindowScene)?.delegate as? SceneDelegate)?.window?.safeAreaInsets ?? UIEdgeInsets.zero
        }
    }
    
    // MARK: - UISceneDelegeate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // MARK: - UIWindowScene
        guard let windowScene = scene as? UIWindowScene else {
            print("\(#file)/\(#line) - Couldn't unwrap the UIWindowScene object")
            return
        }
        
        // MARK: - UIWindow
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = MainNavigationController()
        self.window?.makeKeyAndVisible()
    }
}
