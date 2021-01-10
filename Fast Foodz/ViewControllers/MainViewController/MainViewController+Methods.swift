//
//  MainViewController+Methods.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import CoreLocation
import NavigationTransitionController



/**
 Abstract: Custom sourcefile used to accomodate the MainViewController class with methods
 - manageLocationAccess
 - stopUpdatingLocation
 - scrollToIndex
 - getFrameOfViewController
 - isControllerVisible
 */
extension MainViewController {
    /// Called whenever the location permission should be delegated
    /// - Parameter sender: Any object that calls this method
    @objc func manageLocationAccess(_ sender: Any) {
        // MARK: - CLLocationAuthorizationStatus
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // MARK: - CLLocationManager
            clLocationManager.requestWhenInUseAuthorization()
        case .denied:
            // MARK: - UIAlertController
            let alertController = UIAlertController.init(title: "Please Enable Location", message: "You've denied access to your location for Fast Foodz. Change this in the app's settings to discover great fast food places.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action: UIAlertAction) in
                if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                    // Open the settings
                    UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                }
            }))
            present(alertController, animated: true, completion: nil)
        default: break;
        }
    }
    
    /// Method to stop the CLLocationManager from updating the location — not calling this method properly will imply significant overhead on the user's device
    @objc func stopUpdatingLocation() {
        // MARK: - CLLocationManager
        clLocationManager.stopUpdatingLocation()
    }
    
    /// Toggle the currently visible screen
    /// - Parameter sender: A UISegmentedControl object that calls this method
    @objc func toggleMode(_ sender: UISegmentedControl) {
        // MARK: - UISegmentedControl
        self.scrollToIndex(index: self.segmentedControl.selectedSegmentIndex)
    }
    
    /// Scrolls to the view controller's view in this scroll view class with its index position.
    /// - Parameter index: An Int value representing the view controller's index position.
    /// - Parameter success: A Boolean value indicating whether the scroll view scrolled to the speciied index.
    func scrollToIndex(index: Int, completion: ((_ success: Bool) -> ())? = nil) {
        // Get the contentOffset
        let contentOffset = CGPoint(x: pageSize.width * CGFloat(index), y: 0)

        // Scroll to the view controller
        scrollView.setContentOffset(contentOffset, animated: true)

        // Pass the values in the completion handler
        completion?(true)
    }

    /// Gets the frame of the view controller relative to its position in the scroll view.
    /// - Parameter index: An Int value of the view controller's position in the scroll view.
    func getFrameOfViewController(index: Int) -> CGRect {
        return CGRect(x: CGFloat(index) * pageSize.width, y: 0, width: pageSize.width, height: pageSize.height)
    }

    /// Determines whether the view controller is visible and set as the current view controller.
    /// - Parameter controller: A UIViewController to determine whether the view controller is currently visible in the scroll view's center.
    func isControllerVisible(controller: UIViewController) -> Bool {
        // Loop through the view controllers
        for i in 0..<viewControllers.count {
            /**
             If the view controller at the specified index is the parameter's view controller, return true. We want to loop through this to ensure that the background color transition occurs when the scroll view scrolls
             */
            if viewControllers[i] == controller {
                // Get the parameter view controller's frame
                let controllerFrame = getFrameOfViewController(index: i)
                // Determine whether the view controller view's frame intersects in the scroll view's bounds
                return controllerFrame.intersects(scrollView.bounds)
            }
        }
        return false
    }
}
