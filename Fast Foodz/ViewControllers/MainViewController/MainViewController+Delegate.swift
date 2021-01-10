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



// MARK: - MainDataDelegate
extension MainViewController: MainDataDelegate {
    func updatedLocation(_ location: CLLocation?) {
        /**
         We use a delegate because we don't want to query multiple times for data
         */
        
        // MARK: - MapViewController
        mapViewController.addAnnotationsWithCurrentLocation()
        
        // MARK: - MapListViewController
        mapListViewController.loadData(self)
    }
}



// MARK: - UIScrollViewDelegate
extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update the index of the currently visible collection view object in the scroll view
        self.index = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        
        // Here, when the scroll view finishes scroll, we want to cancel any previous requests made to ```scrollViewDidEndScrollingAnimation``` after 0 seconds
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(scrollViewDidEndScrollingAnimation(_:)), with: nil, afterDelay: 0.0)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Store the previous UIViewController
        let previousViewController: UIViewController? = currentViewController
        
        /**
         Set the current view controller
         */
        if isControllerVisible(controller: mapViewController) {
            // MARK: - MapViewController
            currentViewController = mapViewController
        
        } else if isControllerVisible(controller: mapListViewController) {
            // MARK: - MapListViewController
            currentViewController = mapListViewController
        }
        
        // Execute after 6 milliseconds
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6)) {
            // Call the previous view controller's view controller life cycle's ```viewDidDisappear``` method
            previousViewController?.viewDidDisappear(true)
            // Call the current view controller's view controller life cycle's ```viewDidAppear``` method
            self.currentViewController?.viewDidAppear(true)
        }
    }
}



// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // MARK: - CLLocation
        guard let location = manager.location else {
            print("\(#file)/\(#line) - Couldn't unwrap the CLLocation")
            return
        }
        
        // MARK: - MainData
        // Update the user's current location
        MainData.currentLocation = testLocation ?? location
        
        // Stop updating the location once found to reduce overhead and optimize CPU performance
        clLocationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(#file)/\(#line) - Error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            // Hide/show the view objects
            self.enableLocationButton.alpha = CLLocationManager.authorizationStatus() == .authorizedWhenInUse ? 0.0 : 1.0
            self.scrollView.alpha = CLLocationManager.authorizationStatus() == .authorizedWhenInUse ? 1.0 : 0.0
        }
        
        // Only execute the following codeblock if the authorization status was successful
        guard status == .authorizedWhenInUse else {
            print("\(#file)/\(#line) - CLAuthorizationStatus was not authorized: \(status.rawValue)")
            return
        }
        
        // MARK: - CLLocationManager
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingLocation()
    }
}
