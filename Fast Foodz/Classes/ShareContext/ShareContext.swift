//
//  ShareContext.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/10/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit



/**
 Abstract: Custom class used to display the UIActivityViewController without dismissing the presenting view controller persisted in iOS 13 and up.
 */
class ShareContext {
    
    /// Present the UIActivityViewController without dismissing the presenting view controller
    /// - Parameter items: An array of Any objects used to present in the UIActivityViewController class
    /// - Parameter viewController: An optional UIViewController to present the mock view controller with its UIActivityViewController over. If none is passed, we fall back to the top view controller presented in the application's window
    /// - Parameters:
    ///         - error: An optional Error object returned if the operation fails
    static func present(items: [Any], viewController: UIViewController?, completion: ((_ error: Error?) -> ())? = nil) {
        // Ensure the items aren't empty
        guard items.isEmpty == false else {
            // Pass the value in the completion
            completion?(LocalError(message: "\(#file)/\(#line) - Can't present UIActivityViewController with no data"))
            return
        }
        
        // Execute in the main thread
        DispatchQueue.main.async {
            // MARK: - UIViewController
            // Initialize a mock view controller
            let mockViewController = UIViewController()
            mockViewController.modalPresentationStyle = .overFullScreen
            mockViewController.view.backgroundColor = .clear
            mockViewController.view.alpha = 0.0

            // MARK: - UIActivityViewController
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.completionWithItemsHandler = { (type: UIActivity.ActivityType?, success: Bool, items: [Any]?, error: Error?) in
                (mockViewController.presentingViewController ?? mockViewController).dismiss(animated: false) {
                    // Pass the values in the completion
                    completion?(success ? nil : LocalError(message: "\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)"))
                }
            }
            (viewController ?? UIApplication.topViewController)?.present(mockViewController, animated: false, completion: {
                mockViewController.present(activityVC, animated: true)
            })
        }
    }
}
